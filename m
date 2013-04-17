From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH net-next] net: cdc_ether: silence sparse __CHECK_ENDIAN__ warning
Date: Wed, 17 Apr 2013 16:52:34 +0800
Message-ID: <CACVXFVMbaQZhx-Obh0Jbj7iZaErhZwq0DcSYfgE7ta0HVffpJg@mail.gmail.com>
References: <1366186333-5378-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59485 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965864Ab3DQIwh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 04:52:37 -0400
Received: from mail-ve0-f179.google.com ([209.85.128.179])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1USO6W-0008Kc-0X
	for netdev@vger.kernel.org; Wed, 17 Apr 2013 08:52:36 +0000
Received: by mail-ve0-f179.google.com with SMTP id oz10so1244058veb.10
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 01:52:34 -0700 (PDT)
In-Reply-To: <1366186333-5378-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Apr 17, 2013 at 4:12 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Remove warning introduced by commit 418fc57 ("usbnet: cdc-ether: appl=
y
> usbnet_link_change"):
>
>    CHECK   .../drivers/net/usb/cdc_ether.c
>  .../drivers/net/usb/cdc_ether.c:409:46: warning: incorrect type in a=
rgument 2 (different base types)
>  .../drivers/net/usb/cdc_ether.c:409:46:    expected bool [unsigned] =
[usertype] <noident>
>  .../drivers/net/usb/cdc_ether.c:409:46:    got restricted __le16 [us=
ertype] wValue
>
> Cc: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Thanks for the fix.

        Acked-by: Ming Lei <ming.lei@canonical.com>


Thanks,
--
Ming Lei
