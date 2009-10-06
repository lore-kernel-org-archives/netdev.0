From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 6/9] vxge: Check if FCS stripping is disabled
 by the firmware.
Date: Tue, 06 Oct 2009 08:47:35 +0200
Message-ID: <4ACAE807.4030708@gmail.com>
References: <Pine.GSO.4.10.10910050755480.9377-100000@guinness> <4AC9EEE0.5000601@gmail.com> <78C9135A3D2ECE4B8162EBDCE82CAD7705C16350@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45745 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbZJFGuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 02:50:35 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16350@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa a =E9crit :
> [Ram] The minimum frame size that can be received by the hardware is =
57
> Bytes. A 64 Byte Ethernet frame with the vlan tag and fcs stripped wi=
ll
> result in a 56 Byte frame which will lock up the receive engine. The
> work around is to disable fcs stripping in the hardware which is a
> privileged operation done with a firmware version that the driver che=
cks
> for currently.

Thanks for the info, this could be added in Changelog or some comment, =
as it
might help to diagnose similar problems elsewhere :)
