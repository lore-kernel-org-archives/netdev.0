From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] sys_sendmsg() alignment bug fix
Date: Mon, 26 Sep 2005 14:28:18 -0700 (PDT)
Message-ID: <20050926.142818.47709558.davem@davemloft.net>
References: <1127764921.6529.60.camel@tdi>
	<20050926133634.657ef4a3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932326AbVIZV2d@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20050926133634.657ef4a3.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 26 Sep 2005 13:36:34 -0700

> OK, thanks - I'll send this on to davem.  It seems odd to be using
> __kernel_size_t rather than size_t, but that's what struct cmshdr does
> (also oddly).

Applied, thanks.
