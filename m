From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: linux-next: build failure after merge of the net-next tree
Date: Thu, 18 Feb 2016 22:14:41 +0000
Message-ID: <CO2PR11MB0088B5140CE07D0AC952E23C97AF0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <20160218122855.55e3f09d@canb.auug.org.au>
 <20160218.152835.353900764459662279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0104.outbound.protection.outlook.com ([157.56.110.104]:64032
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757190AbcBRW3k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 17:29:40 -0500
In-Reply-To: <20160218.152835.353900764459662279.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > After merging the net-next tree, today's linux-next build (powerpc
> > ppc64_defconfig) failed like this:
> >
> > In file included from drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:56:0,
> >                  from drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:30:
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c: In function
> 'bnx2x_dcbx_get_ap_feature':
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: error:
> 'DCBX_APP_SF_DEFAULT' undeclared (first use in this function)
> >            DCBX_APP_SF_DEFAULT) &&
> >            ^
> > Caused by commit
> >
> >   e5d3a51cefbb ("This adds support for default application priority.")
> >
> > This build is big endian.
> 
> Yuval and Ariel, you _MUST_ fix this.
> 
> This build failure has been in the tree for 24 hours and I haven't heard anything
> from you two yet.

Hi Dave,

Perhaps I wasn't clear enough in the title I've provided for the fixing patch,
but I've sent it yesterday and it's marked as 'under review' for net-next.
The patch is "bnx2x: Add missing HSI for big-endian machines".

Sorry about all the noise.
