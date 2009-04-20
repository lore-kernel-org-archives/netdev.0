From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Allow fragmentation of VLAN packets traversing a bridge.
Date: Mon, 20 Apr 2009 17:13:24 +0200
Message-ID: <49EC9114.9040301@trash.net>
References: <49E89E0D.5080000@gmail.com> <49E8A6DF.3040905@trash.net> <49E8B73C.7080004@gmail.com> <49E8BA68.50605@trash.net> <49E907E2.3020304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Saikiran Madugula <hummerbliss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbZDTPNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 11:13:30 -0400
In-Reply-To: <49E907E2.3020304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saikiran Madugula wrote:
> br_nf_dev_queue_xmit only checks for ETH_P_IP packets for fragmenting but not
> VLAN packets. This results in dropping of large VLAN packets. This can be
> observed when connection tracking is enabled. Connection tracking re-assembles
> fragmented packets, and these have to re-fragmented when transmitting out. Also,
> make sure only refragmented packets are defragmented as per suggestion from
> Patrick McHardy.

Applied, thanks Saikiran.
