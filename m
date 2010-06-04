From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: net-next Build error in qlogic driver from randconfig.
Date: Fri, 4 Jun 2010 23:23:02 +1000
Message-ID: <AANLkTin7jGpJ7y0MgU93jek5vsXoUFCpjcpHAP5LtyXd@mail.gmail.com>
References: <1275657622.8635.13.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59200 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934Ab0FDNXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 09:23:03 -0400
Received: by iwn37 with SMTP id 37so984244iwn.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 06:23:02 -0700 (PDT)
In-Reply-To: <1275657622.8635.13.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry ignore, i see it just got fixed.

On Fri, Jun 4, 2010 at 11:20 PM, Andrew Hendry <andrew.hendry@gmail.com> wrote:
>
> net-next currently gives a build error from a randconfig.
> # CONFIG_INET is not set
> CONFIG_QLCNIC=m
>
> ERROR: "qlcnicvf_set_ilb_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
> ERROR: "qlcnicvf_config_bridged_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
> ERROR: "qlcnicvf_config_led" [drivers/net/qlcnic/qlcnic.ko] undefined!
> ERROR: "qlcnicvf_clear_ilb_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
> ERROR: "qlcnicvf_start_firmware" [drivers/net/qlcnic/qlcnic.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> make: *** Waiting for unfinished jobs....
>
>
>
