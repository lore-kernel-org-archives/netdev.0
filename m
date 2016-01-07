From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] mlxsw: spectrum: remove FDB entry in case
 we get unknown object notification
Date: Thu, 7 Jan 2016 11:47:12 +0100
Message-ID: <20160107104712.GD2295@nanopsycho.orion>
References: <1452158701-15747-2-git-send-email-jiri@resnulli.us>
 <201601071825.Hwvx9UNt%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33253 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbcAGKrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:47:18 -0500
Received: by mail-wm0-f46.google.com with SMTP id f206so92464185wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 02:47:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201601071825.Hwvx9UNt%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 07, 2016 at 11:27:09AM CET, lkp@intel.com wrote:
>Hi Jiri,
>
>[auto build test WARNING on net-next/master]
>
>url:    https://github.com/0day-ci/linux/commits/Jiri-Pirko/mlxsw-spectrum-pass-local_port-to-mlxsw_sp_port_fdb_uc_op/20160107-172927
>
>
>coccinelle warnings: (new ones prefixed by >>)
>
>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:1122:32-40: ERROR: mlxsw_sp_port is NULL but dereferenced.
>   drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:1062:35-43: ERROR: mlxsw_sp_port is NULL but dereferenced.

Fixing this and sending v2.
