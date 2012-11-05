From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH net-next 0/2] cpsw: fix resource leak for v3.8
Date: Mon, 5 Nov 2012 08:40:34 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293EA0A1EC@DBDE01.ent.ti.com>
References: <cover.1351930782.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:57219 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052Ab2KEIko convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 03:40:44 -0500
In-Reply-To: <cover.1351930782.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Saturday, November 03, 2012 1:55 PM
> To: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org; David Miller; Chemparathy,
> Cyril; N, Mugunthan V; Hiremath, Vaibhav
> Subject: [PATCH net-next 0/2] cpsw: fix resource leak for v3.8
> 
> While looking at the idea of removing all of the register offsets in
> the CPSW's device tree, I noticed that the driver would be leaking IO
> mappings. Although this is, strictly speaking, a bug fix, still it can
> wait to appear in v3.8, since there is no way to use the driver in
> v3.7 (or earlier) anyhow.
> 
> Thanks,
> Richard
> 
> 
> Richard Cochran (2):
>   cpsw: rename register banks to match the reference manual, part 2
>   cpsw: fix leaking IO mappings
> 
>  drivers/net/ethernet/ti/cpsw.c |   39 +++++++++++++++++++-------------
> -------
>  1 files changed, 19 insertions(+), 20 deletions(-)
> 
> --
> 1.7.2.5

The patches look good to me.

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
