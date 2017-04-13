From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR
 for Telit PID 0x1201
Date: Thu, 13 Apr 2017 12:36:51 -0400 (EDT)
Message-ID: <20170413.123651.102212178600257027.davem@davemloft.net>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: dnlplm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbdDMQgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:36:53 -0400
In-Reply-To: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Palmas <dnlplm@gmail.com>
Date: Mon, 10 Apr 2017 17:34:23 +0200

> Telit LE920A4 uses the same pid 0x1201 of LE920, but modem
> implementation is different, since it requires DTR to be set for
> answering to qmi messages.
> 
> This patch replaces QMI_FIXED_INTF with QMI_QUIRK_SET_DTR: tests on
> LE920 have been performed in order to verify backward compatibility.
> 
> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>

Applied, thank you.
