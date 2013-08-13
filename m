From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net v5 1/5] bnx2x: protect different statistics flows
Date: Tue, 13 Aug 2013 13:54:15 -0400
Message-ID: <CADVnQy=0-fjoRDp_u2RzO7dkUmg84V2Q+tNXW0ir=M23V8hALw@mail.gmail.com>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
	<1376349903-3461-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	Ariel Elior <ariele@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:50393 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886Ab3HMRyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:54:16 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so4346376eek.2
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 10:54:15 -0700 (PDT)
In-Reply-To: <1376349903-3461-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 7:24 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> Add locking to protect different statistics flows from
> running simultaneously.
> This in order to serialize statistics requests sent to FW,
> otherwise two outstanding queries may cause FW assert.
>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  2 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  1 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 66 ++++++++++++++++++-----
>  3 files changed, 57 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index d80e34b..98be67f 100644

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks!

neal
