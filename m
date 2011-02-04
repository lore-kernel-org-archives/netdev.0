From: Stuart Longland <redhatter@gentoo.org>
Subject: Configuring IPsec within a user application?
Date: Fri, 04 Feb 2011 19:58:07 +1000
Message-ID: <4D4BCDAF.6000705@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ossa.mas.viperplatform.net.au ([202.147.75.25]:47115 "EHLO
	ossa.mas.viperplatform.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752996Ab1BDKZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 05:25:43 -0500
Received: from mail by ossa.mas.viperplatform.net.au with spam-scanned (Exim 4.43)
	id 1PlIR2-0003ds-LL
	for netdev@vger.kernel.org; Fri, 04 Feb 2011 20:58:36 +1100
Received: from eryx.mas.viperplatform.net.au ([172.16.5.11])
	by ossa.mas.viperplatform.net.au with esmtp (Exim 4.43)
	id 1PlIR2-0003dp-K5
	for netdev@vger.kernel.org; Fri, 04 Feb 2011 20:58:36 +1100
Received: from mail by eryx.mas.viperplatform.net.au with spam-scanned (Exim 4.43)
	id 1PlIR2-0006Xo-4X
	for netdev@vger.kernel.org; Fri, 04 Feb 2011 20:58:36 +1100
Received: from [172.16.100.13] (helo=helicon.mas.viperplatform.net.au)
	by eryx.mas.viperplatform.net.au with esmtp (Exim 4.43)
	id 1PlIR2-0006Xl-3a
	for netdev@vger.kernel.org; Fri, 04 Feb 2011 20:58:36 +1100
Received: from [203.94.56.252] (helo=atomos.dmz.longlandclan.yi.org)
	by helicon.mas.viperplatform.net.au with esmtp (Exim 4.43)
	id 1PlIR0-0005hk-HM
	for netdev@vger.kernel.org; Fri, 04 Feb 2011 20:58:36 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm not sure if this is the right list or not, if not I'd appreciate a
referral to a more appropriate list.

I've been toying with the idea of a small multicast VoIP/digital comms
protocol=C2=B9 for use over wireless radio links.  The typical use case=
 might
be to replace UHF FM radio transceivers with modern smart phones, using
multicast IPv6 networking over 802.11b.  (It will have other modes too,
transmission over amateur radio bands for instance.)

In some commercial settings, or over the Internet, it'd be great for
traffic to be authenticated using HMAC-SHA1 or even encrypted.  Looking
at IPsec, I see it provides exactly this.  My thought, why re-invent th=
e
wheel when a solution may already exist?

The question though:  Is it possible for a userspace application
(non-privileged) to request that the UDP packets it generates/receives
from/to a particular address be encrypted or hashed against a specified=
 key?

i.e. if I decide to communicate with someone on the same wireless link,
and by means of asymmetric crypto at higher layers we establish a share=
d
AES key, can I configure the stack for traffic between these two hosts
on-the-fly and without root privileges?

Regards,
--=20
Stuart Longland (aka Redhatter, VK4MSL)      .'''.
Gentoo Linux/MIPS Cobalt and Docs Developer  '.'` :
=2E . . . . . . . . . . . . . . . . . . . . .   .'.'
http://dev.gentoo.org/~redhatter             :.'

I haven't lost my mind...
  ...it's backed up on a tape somewhere.

1. http://wongi.longlandclan.yi.org
