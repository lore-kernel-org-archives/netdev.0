From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/8] generic_hdlc: Update to current logging forms
Date: Thu, 21 Jul 2011 21:18:04 +0200
Message-ID: <m3d3h3e93n.fsf@intrepid.localdomain>
References: <cover.1309150683.git.joe@perches.com>
	<d9186716ad410d64b1e09b39408a2f232f178260.1309150684.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d9186716ad410d64b1e09b39408a2f232f178260.1309150684.git.joe@perches.com>
	(Joe Perches's message of "Sun, 26 Jun 2011 22:01:28 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> Use pr_fmt, pr_<level> and netdev_<level> as appropriate.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wan/c101.c       |   30 +++++++-------
>  drivers/net/wan/hd64570.c    |    8 ++--
>  drivers/net/wan/hd64572.c    |    8 ++--
>  drivers/net/wan/hdlc.c       |   16 ++++---
>  drivers/net/wan/hdlc_cisco.c |   21 ++++------
>  drivers/net/wan/hdlc_fr.c    |   96 +++++++++++++++++++-----------------------
>  drivers/net/wan/hdlc_ppp.c   |    9 ++--
>  drivers/net/wan/hdlc_x25.c   |   12 ++---
>  drivers/net/wan/n2.c         |   42 +++++++++---------
>  drivers/net/wan/pc300too.c   |   36 +++++++--------
>  drivers/net/wan/pci200syn.c  |   29 ++++++-------
>  drivers/net/wan/wanxl.c      |   90 ++++++++++++++++++---------------------

Looks good. I'll do some tests and then pass upstream. Thanks.
-- 
Krzysztof Halasa
