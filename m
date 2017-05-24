From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next v2 7/8] mlxsw: spectrum: Validate firmware
 revision on init
Date: Wed, 24 May 2017 08:42:50 +0300
Message-ID: <20170524054250.GB12582@splinter.mtl.com>
References: <20170523195630.6460-1-jiri@resnulli.us>
 <20170523195630.6460-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <yotamg@mellanox.com>, <mlxsw@mellanox.com>,
        <Yuval.Mintz@cavium.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30080.outbound.protection.outlook.com ([40.107.3.80]:50784
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S938289AbdEXFm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 01:42:58 -0400
Content-Disposition: inline
In-Reply-To: <20170523195630.6460-8-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 09:56:29PM +0200, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Make the spectrum module check the current device firmware version, and if
> it is below the supported version, use the libfirmware API to request a
> firmware file with the supported firmware version and flash it to the
> device using the mlxfw module.
> 
> The firmware file names are expected to be of Mellanox Firmware Archive
> version 2 (MFA2) format and their name are expected to be in the following
> pattern: "mlxsw_spectrum-<major>.<minor>.<sub-minor>.mfa2".
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
