From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: net-next Build error in qlogic driver from randconfig.
Date: Fri, 04 Jun 2010 23:20:22 +1000
Message-ID: <1275657622.8635.13.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:39017 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab0FDNWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 09:22:46 -0400
Received: by pwi3 with SMTP id 3so123302pwi.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 06:22:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net-next currently gives a build error from a randconfig.
# CONFIG_INET is not set
CONFIG_QLCNIC=m

ERROR: "qlcnicvf_set_ilb_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
ERROR: "qlcnicvf_config_bridged_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
ERROR: "qlcnicvf_config_led" [drivers/net/qlcnic/qlcnic.ko] undefined!
ERROR: "qlcnicvf_clear_ilb_mode" [drivers/net/qlcnic/qlcnic.ko] undefined!
ERROR: "qlcnicvf_start_firmware" [drivers/net/qlcnic/qlcnic.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2
make: *** Waiting for unfinished jobs....


