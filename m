From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ieee802154: verify packet size before trying to
 allocate it
Date: Sun, 08 Jul 2012 23:50:05 -0700 (PDT)
Message-ID: <20120708.235005.1770661412478433472.davem@davemloft.net>
References: <1341228595-9883-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341228595-9883-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon,  2 Jul 2012 13:29:55 +0200

> Currently when sending data over datagram, the send function will attempt to
> allocate any size passed on from the userspace.
> 
> We should make sure that this size is checked and limited. We'll limit it
> to the MTU of the device, which is checked later anyway.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Applied.
