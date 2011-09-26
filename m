From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 15:42:25 -0700
Message-ID: <20110926154225.76514656@nehalam.linuxnetplumber.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110917204257.GA2636@torres.zugschlus.de>
	<1316550027.1783.102.camel@dcbw.foobar.com>
	<20110925082504.GA32712@torres.zugschlus.de>
	<20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
	<4E80DA4D.3090404@gmail.com>
	<20110926130507.1435d76b@nehalam.linuxnetplumber.net>
	<4E80F8BD.4010401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54380 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480Ab1IZWm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 18:42:28 -0400
In-Reply-To: <4E80F8BD.4010401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> And this might also allow to set an IPv6 address on a dummy interface, which Marc Haber reported as 
> not being allowed for now, probably because DAD cannot succeed on a dummy interface and as such, a 
> bind() cannot be allowed, and as such, setting the IPv6 address is currently useless.

For dummy, the interface should probably have the IFF_NOARP flag set.
There isn't any point in doing network discovery on a non-connected
interface. That would make DAD a no-op and bind would work.
