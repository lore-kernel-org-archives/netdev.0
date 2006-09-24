From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sun, 24 Sep 2006 01:11:21 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609240106270.24276@d.namei>
References: <20060922112948.GA17335@2ka.mipt.ru> <20060922121920.GA3172@2ka.mipt.ru>
 <4513D5B5.6090301@trash.net> <20060922140318.GA14408@2ka.mipt.ru>
 <Pine.LNX.4.64.0609221112000.7628@d.namei> <20060923042914.GC24099@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:65417 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751313AbWIXFLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 01:11:25 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060923042914.GC24099@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Sep 2006, Evgeniy Polyakov wrote:

> I never saw unencrypted packets before.

It's normal and expected, perhaps you didn't notice or had tcpdump 
filtering them.

> > > 17:45:11.102212 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x01f452be,seq=0x3), length 84
> > > 17:45:12.098146 IP 192.168.4.79.isakmp > 192.168.4.78.isakmp: isakmp: phase 2/others ? oakley-quick[E]
> > > 17:45:12.098427 IP 192.168.4.78.isakmp > 192.168.4.79.isakmp: isakmp: phase 2/others ? inf
> > 
> > And why racoon packets are here at this stage.
> > 
> > Can you try this with either a fully manual config (setkey only) or 
> > openswan?
> 
> I use racoon, may be there are some problems with it's version, I will
> try new one after weekend.

I just verified that racoon is working with current kernels.  Racoon can 
be troublesome.  

I'm using racoon from ipsec-tools-0.6.5-3.1.

You didn't specify a lifetime in your phase 1 spec ('remote anonymous') 
section.  Not sure what happens in that case, could be something to do 
with it.




- James
-- 
James Morris
<jmorris@namei.org>
