From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] move some code to net/ipx/af_ipx.c
Date: Sat, 4 Feb 2006 09:19:42 +0000
Message-ID: <20060204091942.GA19863@infradead.org>
References: <20060204010958.GY4408@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, acme@conectiva.com.br,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946001AbWBDJTy@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060204010958.GY4408@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 04, 2006 at 02:09:59AM +0100, Adrian Bunk wrote:
> This patch moves some code only used in this file to net/ipx/af_ipx.c .

this doesn't make any sense.  the code is part of the 802.2/3 layer, not the
ipx layer even if no other protocol makes use of it yet.
