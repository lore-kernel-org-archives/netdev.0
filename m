From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next PATCH 5/5] r8169: Use eth_skb_pad function
Date: Wed, 26 Nov 2014 01:02:58 +0100
Message-ID: <20141126000258.GA5901@electric-eye.fr.zoreil.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
 <20141125224425.1867.70460.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58975 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbaKZADP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 19:03:15 -0500
Content-Disposition: inline
In-Reply-To: <20141125224425.1867.70460.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck <alexander.h.duyck@redhat.com> :
> Replace rtl_skb_pad with eth_skb_pad since they do the same thing.

rtl_skb_pad returns true on success.

eth_skb_pad returns 0 on success.

-- 
Ueimor
