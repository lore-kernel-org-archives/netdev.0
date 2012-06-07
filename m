From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: verify packet size before trying to
 allocate it
Date: Thu, 07 Jun 2012 13:10:36 -0700 (PDT)
Message-ID: <20120607.131036.454649403537424443.davem@davemloft.net>
References: <1339018322-19360-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339018322-19360-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <levinsasha928@gmail.com>
Date: Wed,  6 Jun 2012 23:32:02 +0200

> Currently when sending data over datagram, the send function will attempt to
> allocate any size passed on from the userspace.
> 
> We should make sure that this size is checked and limited. The maximum size
> of an IP packet seemed like the safest limit here.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

This limit is arbitrary, I'm not applying a patch like this.

Use the actual limit, which is either the protocol limit or something
like the device mtu.
