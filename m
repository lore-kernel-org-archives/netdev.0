From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Mon, 12 Oct 2009 18:07:30 -0400
Message-ID: <1255385250.5406.43.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
	 <200910121715.35676.denys@visp.net.lb>
	 <1255381064.5406.30.camel@dogo.mojatatu.com>
	 <200910130054.23237.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:59065 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbZJLWLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 18:11:37 -0400
Received: by qw-out-2122.google.com with SMTP id 9so691157qwb.37
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 15:10:30 -0700 (PDT)
In-Reply-To: <200910130054.23237.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-13 at 00:54 +0300, Denys Fedoryschenko wrote:
> I don't have problem with existing behaviour, since i am using other way of 
> shaping, for my case using pktedit to assign priority to SKB and shaping by 
> it.

I am dissapointed Denys, you dont like ipt?;->

> But generally problem is was told by one of russian developers who is working 
> on firmware for few models of broadband routers, he asked to help on ISP 
> forum, and if possible to explain this to someone who can give advice, and 
> maybe tell that probably there is a bug.

[..]

> If it is not, then just simple question, it will work reliably if i just use 
> u32 filter with offset on ifb?

Yes, of course you can if you add offset sizeof pppoe header.
But:
It looks like there is a genuine need for this feature.

The challenge is: I am trying to be generic across devices of many
different types (ethernet, atm, virtual etc) at many entry points,
ingress, egress local, forwarding etc. 
This feature that this person would need will only work if you _know_
what you are doing; i.e in this case, I can very easily turn it off with
a simple command - but the user must know that they do this on ingress
side. I can cook a very quick patch for kernel and user space - you
think this user can test it?

cheers,
jamal

