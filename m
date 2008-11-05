From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 05 Nov 2008 12:02:21 +0100
Message-ID: <49117D3D.7070702@trash.net>
References: <1225882507.5273.66.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34926 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbYKELC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 06:02:29 -0500
In-Reply-To: <1225882507.5273.66.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johann Baudy wrote:
> I would like to integrate this barrier mechanism in __packet_[set|
> get]_status() function. Thoughts?

The reason why its not in there is to avoid the unnecessary
barrier when setting up the ring in packet_set_ring().

The code is fishy though, I agree. Have a look at this discussion:

http://marc.info/?l=linux-netdev&m=119383985207984&w=2
