From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Sun, 12 Sep 2004 17:05:05 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040912170505.62916147.davem@davemloft.net>
References: <20040911194108.GS28258@stingr.sgu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S264299AbUIMAGj@vger.kernel.org>
To: Paul P Komkoff Jr <i@stingr.net>
In-Reply-To: <20040911194108.GS28258@stingr.sgu.ru>
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 23:41:08 +0400
Paul P Komkoff Jr <i@stingr.net> wrote:

> Some time ago I posted the following patch.
> It indeed adds support for wccp version 1 and 2 decapsulation in
> ip_gre.c. But there is an open question.
> I surrounded all decapsulation stuff in if (1).
> Which knob I should use instead of that 1 to make this change
> acceptable into mainline kernel?

What are the rules for IP_GRE in general for when
to apply this transformation?

Please do me a favor also, and redo your patch by putting
ETH_P_WCCP into include/linux/if_ether.h where it belongs.

Thanks.
