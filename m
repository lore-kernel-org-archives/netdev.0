From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Wed, 14 Oct 2009 08:00:27 -0400
Message-ID: <1255521627.21940.1.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
	 <200910130144.04910.denys@visp.net.lb>
	 <1255436477.6305.2.camel@dogo.mojatatu.com>
	 <200910131545.36946.denys@visp.net.lb>
	 <1255438959.6305.13.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:42916 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353AbZJNMEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 08:04:07 -0400
Received: by qyk2 with SMTP id 2so9659480qyk.21
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 05:03:30 -0700 (PDT)
In-Reply-To: <1255438959.6305.13.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-13 at 09:18 -0400, jamal wrote:

> Ok - makes sense. I know some people using mark for ingress pseudo RPF.
> And given instability of netfilter interface, I may just end up patching
> skbedit.


Ok, I just whipped a quick patch for skbedit to set the mark - and it
seems to work well after some basic testing. I will post.

cheers,
jamal

