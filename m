From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] Documentation: ABI: testing: sysfs-class-net-qmi: add
 new qmap mux files description
Date: Fri, 24 Mar 2017 19:31:30 +0300
Message-ID: <8982c186-0560-a426-2873-bc21bc2f1765@cogentembedded.com>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
 <1490361766-24114-3-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Daniele Palmas <dnlplm@gmail.com>,
        =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35550 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757367AbdCXQbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 12:31:35 -0400
Received: by mail-lf0-f53.google.com with SMTP id j90so3242892lfk.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 09:31:34 -0700 (PDT)
In-Reply-To: <1490361766-24114-3-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 03/24/2017 04:22 PM, Daniele Palmas wrote:

> This patch updates the documentation related to the new files added for
> qmap mux support.
>
> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
> ---
>  Documentation/ABI/testing/sysfs-class-net-qmi | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
>
> diff --git a/Documentation/ABI/testing/sysfs-class-net-qmi b/Documentation/ABI/testing/sysfs-class-net-qmi
> index fa5a00b..5191dc3 100644
> --- a/Documentation/ABI/testing/sysfs-class-net-qmi
> +++ b/Documentation/ABI/testing/sysfs-class-net-qmi
> @@ -21,3 +21,30 @@ Description:
>  		is responsible for coordination of driver and firmware
>  		link framing mode, changing this setting to 'Y' if the
>  		firmware is configured for 'raw-ip' mode.
> +
> +What:		/sys/class/net/<iface>/qmi/add_mux
> +Date:		March 2017
> +KernelVersion:	4.11
> +Contact:	Bjørn Mork <bjorn@mork.no>
> +Description:
> +		Unsigned integer.
> +
> +		Write a number ranging from 1 to 127 to add a qmap mux
> +		based network device, supported by recent Qualcomm based
> +		modems.
> +
> +		The network device will be called qmimux.
> +
> +		Userspace is in charge of managing the qmux network device
> +		activation and data stream setup  on them modem side by

    s/them/the/?

> +		using the proper QMI protocol requests.
[...]

MBR, Sergei
