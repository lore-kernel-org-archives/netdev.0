From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 06:31:47 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FDEEEA283@MNEXMB2.qlogic.org>
References: <cover.1308024069.git.joe@perches.com>
 <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Dillow <dave@thedillows.org>,
	linux-kerne
To: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Joe Perches [mailto:joe@perches.com]
>
> Unnecessary casts of void * clutter the code.
> 
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.
> 
> Done via coccinelle script:
> 
> $ cat cast_void_pointer.cocci
> @@
> type T;
> T *pt;
> void *pv;
> @@
> 
> - pt = (T *)pv;
> + pt = pv;
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/netxen/netxen_nic_ctx.c |   16 ++++++------
>  drivers/net/qlcnic/qlcnic_ctx.c     |   26 ++++++++++----------
>  drivers/net/qlcnic/qlcnic_ethtool.c |    2 +-
>  drivers/net/qlcnic/qlcnic_hw.c      |    3 +-
>  drivers/net/qlcnic/qlcnic_main.c    |    2 +-

netxen_nic and qlcnic looks good.

-Amit
