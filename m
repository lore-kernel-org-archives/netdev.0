From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 04/10] bnxt_en: Added support for Secure Firmware
 Update
Date: Mon, 19 Sep 2016 08:16:46 +0000
Message-ID: <BL2PR07MB23067271DDD44A0E3D31B99A8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-5-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0076.outbound.protection.outlook.com ([104.47.33.76]:17168
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759021AbcISIbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:31:09 -0400
In-Reply-To: <1474271889-8229-5-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	if (bp->hwrm_spec_code < 0x10400)
> +		return -EOPNOTSUPP;
Don't you use defines for these kind of version values?

>  static int bnxt_flash_package_from_file(struct net_device *dev,
...
> +	rc =3D request_firmware(&fw, filename, &dev->dev);
> +	if (rc !=3D 0) {
If (rc)

> +	if ((install_type & 0xffff) =3D=3D 0)
> +		install_type >>=3D 16;
! instead of "=3D=3D 0". Also, this looks 'magical'.
