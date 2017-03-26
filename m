From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: usb: qmi_wwan: add qmap mux protocol support
Date: Sat, 25 Mar 2017 20:03:49 -0700 (PDT)
Message-ID: <20170325.200349.1859365878558524339.davem@davemloft.net>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: bjorn@mork.no, linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: dnlplm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdCZDDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 23:03:51 -0400
In-Reply-To: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Palmas <dnlplm@gmail.com>
Date: Fri, 24 Mar 2017 14:22:44 +0100

> This patch adds support for qmap mux protocol available in recent
> Qualcomm based modems.
> 
> The qmap mux protocol can be used for multiplexing data packets in
> order to have multiple ip streams through the same physical device.
> 
> Two new sysfs files are added for adding/removing the qmap mux based
> interfaces (named qmimux):
> 
> /sys/class/net/<iface>/qmi/add_mux
> /sys/class/net/<iface>/qmi/del_mux
> 
> Main patch author is Bjørn Mork <bjorn@mork.no>
> 
> An userspace implementation of the qmi requests needed to support
> multiple ip streams is already available (namely libqmi since
> version 1.18.0).
> 
> The qmap mux feature has been recently implemented in Codeaurora
> gobinet out-of-kernel driver that was the inspiration for this
> development.
> 
> Tests have been performed with Telit LE922A6 (PID 0x1040)

Series applied, thanks.
