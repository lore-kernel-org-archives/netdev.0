From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 01/15] net: pasemi: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 23:07:11 -0700
Message-ID: <CAOesGMgEz=mE_s6DVFtG5BoRVudX_owzCuJGm_4drwa4xAOxQw@mail.gmail.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
	<000701cecedd$3d7f24c0$b87d6e40$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:50778 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab3JVGHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:07:12 -0400
Received: by mail-qa0-f51.google.com with SMTP id ii20so3061141qab.3
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 23:07:12 -0700 (PDT)
In-Reply-To: <000701cecedd$3d7f24c0$b87d6e40$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 9:14 PM, Jingoo Han <jg1.han@samsung.com> wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Olof Johansson <olof@lixom.net>
