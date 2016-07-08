From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] bnxt_en: initialize rc to zero to avoid returning garbage
Date: Fri, 8 Jul 2016 13:06:08 -0700
Message-ID: <CACKFLiknzsGV9ByNEecszKwWRLa=OFb261rGkdLw5Yn5yU3y4A@mail.gmail.com>
References: <1467992568-1990-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	Rob Swindell <rob.swindell@broadcom.com>,
	Satish Baddipadige <sbaddipa@broadcom.com>,
	Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35429 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbcGHUGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 16:06:09 -0400
Received: by mail-oi0-f51.google.com with SMTP id r2so73469520oih.2
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 13:06:09 -0700 (PDT)
In-Reply-To: <1467992568-1990-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 8:42 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> rc is not initialized so it can contain garbage if it is not
> set by the call to bnxt_read_sfp_module_eeprom_info. Ensure
> garbage is not returned by initializing rc to 0.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks.

Acked-by: Michael Chan <michael.chan@broadcom.com>
