From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 02/12] nfp: set driver VF limit
Date: Sun, 28 May 2017 14:49:58 +0000
Message-ID: <BLUPR0701MB200496130E22B9820F7C1D858DF20@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
 <20170528003411.17603-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0081.outbound.protection.outlook.com ([104.47.36.81]:31150
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750825AbdE1OuB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 10:50:01 -0400
In-Reply-To: <20170528003411.17603-3-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  	pf->limit_vfs =3D nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs",
> &err);
>  	if (!err)
> -		return;
> +		return pci_sriov_set_totalvfs(pf->pdev, pf->limit_vfs);

While you're at it, If you're going to enforce the limit at the PCI level,
shouldn't you retire 'limit_vfs' altogether?

BTW, under which conditions would you expect to find a difference
in the maximal number of VFs?
