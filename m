From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] changes to ucc_geth driver as a result of qe_lib changesand bugfixes
Date: Sat, 7 Oct 2006 12:23:45 +0200
Message-ID: <000101c6e9fa$abc94cf0$020120ac@Jocke>
References: <20061006172229.10b144df.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@ozlabs.org>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 147.175.241.83.in-addr.dgcsystems.net ([83.241.175.147]:9195
	"EHLO tmnt04.transmode.se") by vger.kernel.org with ESMTP
	id S1750787AbWJGKZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Oct 2006 06:25:53 -0400
To: "'Kim Phillips'" <kim.phillips@freescale.com>,
	<netdev@vger.kernel.org>
In-Reply-To: <20061006172229.10b144df.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> changes due to qe_lib changes include:
> 
> o removed platform_device code, replaced with of_device
> o removed typedefs
> o uint -> u32 conversions
> o removed following defines:
>   QE_SIZEOF_BD, BD_BUFFER_ARG, BD_BUFFER_CLEAR, BD_BUFFER,
>   BD_STATUS_AND_LENGTH_SET, BD_STATUS_AND_LENGTH, and BD_BUFFER_SET
>   because they hid sizeof/in_be32/out_be32 operations from the reader.
> o removed irrelevant comments, added others to resemble 
> removed BD_ defines
> o const'd and uncasted all get_property() assignments
> 
> bugfixes, courtesy of Scott Wood, include:
> 
> - Read phy_address as a u32, not u8.
> - Match on type == "network" as well as compatible == "ucc_geth", as
>   device_is_compatible() will only compare up to the length of the
>   test string, allowing "ucc_geth_phy" to match as well.
> - fixes the MAC setting code in ucc_geth.c.  The old code was 
> overwriting and dereferencing random stack contents.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> 
> ---
> 
> Jeff, this patch fixes ucc_geth buildtime and runtime errors; 
> please apply.

Can you send the complete patch againt paulus tree to get ucc_qeth driver going? Currently there
are too many patches floating around.

 Regards
          Joakim

