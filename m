From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 0/9] RFC v2: Multicast and filtering features on AF_UNIX
Date: Mon, 22 Nov 2010 18:34:47 +0000
Message-ID: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcuno
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:38580 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757066Ab0KVSgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 13:36:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a new serie of patches, following my first request for comments
here: http://marc.info/?l=linux-netdev&m=128534977610124

It implements a new multicast features on AF_UNIX datagram and
seqpacket sockets.

My motivation is to use it for D-Bus. The kernel code here does not
contain anything specific to D-Bus, so it could be used for other IPC
mechanisms too.

The patches apply on linux-next-20101122 and can be pulled from:

  git://git.collabora.co.uk/git/user/alban/linux-2.6.35.y/.git unix-multicast5

Comments & questions welcome! I would appreciate a review on the design
and know if it goes in the right direction.

Regards,
Alban Crequy
