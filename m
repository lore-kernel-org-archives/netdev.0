From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] IP_RECVERRC
Date: Fri, 10 Aug 2007 10:30:12 -0400
Message-ID: <1186756212.5163.4.camel@localhost>
References: <1186752912.5188.12.camel@localhost>
	 <20070810140214.GA10331@one.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:46571 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbXHJOaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 10:30:24 -0400
Received: by an-out-0708.google.com with SMTP id d31so160175and
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 07:30:23 -0700 (PDT)
In-Reply-To: <20070810140214.GA10331@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-08 at 16:02 +0200, Andi Kleen wrote:
> On Fri, Aug 10, 2007 at 09:35:12AM -0400, jamal wrote:

> 
> Affected in what way? 
> 

They dont get errors back and they just keep sending even in the
presence of errors - take a look at ip_push_pending_frames. I have been
struggling initially to unconditionally mod that part, but it may break
certain apps expectations.

> > If you set that option though you end up getting all these skbs back
> 
> IP_RECVERR just delivers ICMPs. Do you mean those with "all these skbs" ?

yes - sorry thats what i meant; the app has to do a recvmsg to grab them

> > to the app which i see as unnecessary work if i am uninterested. I would
> > like to not do a recvmsg to find out what those messages are - rather
> > just receiving any errors back.
> > My proposal is to add another option which is mutually exclusive with
> > IP_RECVERR that allows for errors only.
> 
> What ICMPs do you not want? 

All.

cheers,
jamal

