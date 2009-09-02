From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 02 Sep 2009 18:05:20 +0200
Message-ID: <4A9E97C0.2000909@gmail.com>
References: <4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net> <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net> <4A9E849A.30105@gmail.com> <alpine.DEB.1.10.0909021413490.16364@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, mtk.manpages@gmail.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48650 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbZIBQFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 12:05:55 -0400
In-Reply-To: <alpine.DEB.1.10.0909021413490.16364@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> The patch is smaller if you remove the handling of recverr completely=
 from
> ip_push_pending_frames() and return NET_RX_DROP etc. Two of the calle=
rs
> never even inspect the return code. For them this is useless processi=
ng.

We must check NET_XMIT_CN before doing the update, but you are probably=
 right.

I'll cook another patch ASAP, thanks !


