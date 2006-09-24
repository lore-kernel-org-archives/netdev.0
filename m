From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sun, 24 Sep 2006 10:33:37 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609241029410.14827@d.namei>
References: <20060922112948.GA17335@2ka.mipt.ru> <20060922121920.GA3172@2ka.mipt.ru>
 <4513D5B5.6090301@trash.net> <20060922140318.GA14408@2ka.mipt.ru>
 <Pine.LNX.4.64.0609221112000.7628@d.namei> <20060923042914.GC24099@2ka.mipt.ru>
 <Pine.LNX.4.64.0609240106270.24276@d.namei> <45164B02.1090801@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:36302 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750966AbWIXOdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 10:33:41 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45164B02.1090801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Sep 2006, Patrick McHardy wrote:

> James Morris wrote:
> > On Sat, 23 Sep 2006, Evgeniy Polyakov wrote:
> > 
> > 
> >>I never saw unencrypted packets before.
> > 
> > 
> > It's normal and expected, perhaps you didn't notice or had tcpdump 
> > filtering them.
> 
> He's talking about transport mode, unencrypted packet should
> only be visible in tunnel mode.

Ok.

I've done some more testing with local tcpdumps and not seeing any issues.

Evgeniy: if you update to the latest racoon (and kernel), and still see 
it, please send complete logs of 'racoon -dddd' from each side, and also 
'setkey -x', so we can see if the policy entries are being being modified.


- James
-- 
James Morris
<jmorris@namei.org>
