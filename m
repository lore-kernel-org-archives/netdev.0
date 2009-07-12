From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ip_push_pending_frames() fix
Date: Sat, 11 Jul 2009 20:27:02 -0700 (PDT)
Message-ID: <20090711.202702.30626847.davem@davemloft.net>
References: <4A552A0D.8080106@gmail.com>
	<EA929A9653AAE14F841771FB1DE5A1365F8AD4E371@rrsmsx501.amr.corp.intel.com>
	<4A5537DA.1060200@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37360
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbZGLD1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 23:27:05 -0400
In-Reply-To: <4A5537DA.1060200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jul 2009 02:20:42 +0200

> [PATCH] net: ip_push_pending_frames() fix
> 
> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 
> (net: No more expensive sock_hold()/sock_put() on each tx)
> we do not take any more references on sk->sk_refcnt on outgoing packets.
> 
> I forgot to delete two __sock_put() from ip_push_pending_frames()
> and ip6_push_pending_frames().
> 
> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, with the Tested-by marker added.
