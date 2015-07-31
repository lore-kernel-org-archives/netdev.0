From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 0/4] Introduce Mellanox Technologies Switch
 ASICs switchdev drivers
Date: Fri, 31 Jul 2015 10:45:06 -0700
Message-ID: <55BBB422.50808@cumulusnetworks.com>
References: <1438205629-3108-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, tgraf@suug.ch, ast@plumgrid.com,
	jhs@mojatatu.com, daniel@iogearbox.net, john.fastabend@gmail.com,
	simon.horman@netronome.com, linville@tuxdriver.com,
	andy@greyhouse.net, shm@cumulusnetworks.com, nhorman@tuxdriver.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33793 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbbGaRpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 13:45:10 -0400
Received: by pacan13 with SMTP id an13so45045850pac.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 10:45:09 -0700 (PDT)
In-Reply-To: <1438205629-3108-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/15, 2:33 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> This patchset introduces Mellanox Technologies Switch driver infrastructure
> and support for SwitchX-2 ASIC.
>
> The driver is divided into 3 logical parts:
> 1) Bus - implements switch bus interface. Currently only PCI bus is
>     implemented, but more buses will be added in the future. Namely I2C
>     and SGMII.
>     (patch #2)
> 2) Driver - implemements of ASIC-specific functions.
>     Currently SwitchX-2 ASIC is supported, but a plan exists to introduce
>     support for Spectrum ASIC in the near future.
>     (patch #4)
> 3) Core - infrastructure that glues buses and drivers together.
>     It implements register access logic (EMADs) and takes care of RX traps
>     and events.
>     (patch #1 and #3)
>
> Ido Schimmel (1):
>    mlxsw: Add interface to access registers and process events
>
> Jiri Pirko (3):
>    mlxsw: Introduce Mellanox switch driver core
>    mlxsw: Add PCI bus implementation
>    mlxsw: Introduce Mellanox SwitchX-2 ASIC support
>
>
Its really great to see this driver. Thank you Jiri and others @mellanox!.
