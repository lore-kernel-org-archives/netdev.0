From: Paul Hampson <Paul.Hampson@Pobox.com>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 19:49:47 +1100
Message-ID: <455D77AB.907@Pobox.com>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>	<20061114142959.GA17486@keitarou>  <200611161507.33971.mb@bu3sch.de>	<1163749589.5826.5.camel@localhost.localdomain>	<1163750030.4047.1.camel@ux156> <1163750573.5826.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: public-linville-2XuSBdqkA4R54TAoqtyWWQ@ciao.gmane.org,
	Michael Buesch <public-mb-fseUSCV1ubazQB+pC5nmwQ@ciao.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:61894 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1755562AbWKQIuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 03:50:07 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GkzQ3-0007Sx-3h
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 09:49:55 +0100
Received: from hydrogen.aie.net.au ([210.11.234.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Nov 2006 09:49:55 +0100
Received: from Paul.Hampson by hydrogen.aie.net.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Nov 2006 09:49:55 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1163750573.5826.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> On Fri, 2006-11-17 at 08:53 +0100, Johannes Berg wrote:
>> On Fri, 2006-11-17 at 18:46 +1100, Benjamin Herrenschmidt wrote:

>>> So what is the solution for Apple machines owner who only get a v3
>>> firmware from Apple ? I remember you telling me the answer on irc but I
>>> wanted to make it public :-) Some web site we can d/l the windows
>>> updates and extract the FW ?

>> Yes, fwcutter comes with a huge list of URLs for both firmware versions
>> (I suppose they'll remove the v3 ones now...)

v3 ones are still needed for the softmac version, unless I'm badly drunk...

> Well, the latest "released" version (fwcutter-005) contains a huge list
> of ... v3 URLs :-) Only 2 v4 in there. I'll check SVN.

There's actually a v4 big-endian firmware in the fwcutter list in SVN, but
no URL to fetch it from...

It comes from the AppleAirPortBrcm4311 driver. I've no idea where that update
comes from, I found a copy on the Internet somewhere. (I think someone posted
the file to a message board looking for help with it...)

I'm not sure, would it be be bad for me to just stick a copy of it up on a
website? If so, I can prolly dig up the place I got it from (I'm sure I
bookmarked it at the time) and people can choose their own level of comfort.

I have to say it's not clear from the documentation that BE machines like
PPC need to use a BE firmware... (If that's not the case, it's not clear
that it's not the case either, it just doesn't say either way. ^_^)

In fact, given that it's a BE firmware update for Intel-based Macs' bcm
cards, I presume the endianess of the firmware doesn't matter?

-- 
Paul Hampson
Paul.Hampson@Pobox.com

