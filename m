From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH V3] Set NTB format again after altsetting switch for
 Huawei devices
Date: Tue, 11 Jul 2017 23:04:07 +0200
Message-ID: <1499807047.29772.2.camel@suse.com>
References: <20170711152152.30011-1-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
        Christian Panton <christian@panton.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40018 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754515AbdGKVGb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 17:06:31 -0400
In-Reply-To: <20170711152152.30011-1-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 11.07.2017, 17:21 +0200 schrieb Enrico Mioso:
> 
> Some firmwares in Huawei E3372H devices have been observed to switch back
> to NTB 32-bit format after altsetting switch.
> This patch implements a driver flag to check for the device settings and
> set NTB format to 16-bit again if needed.
> The flag has been activated for devices controlled by the huawei_cdc_ncm.c
> driver.

Hi,

does this cover reset_resume()?

	Regards
		Oliver
