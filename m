From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: verify packet size before trying to
 allocate it
Date: Sun, 10 Jun 2012 20:04:43 -0700 (PDT)
Message-ID: <20120610.200443.971015025499077057.davem@davemloft.net>
References: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 10 Jun 2012 13:10:19 +0200

> Currently when sending data over datagram, the send function will attempt to
> allocate any size passed on from the userspace.
> 
> We should make sure that this size is checked and limited. The maximum size
> of an IP packet seemed like the safest limit here.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Why not limit to the device MTU?  That's exactly what I suggested
to you.
