From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: [PATCH net] cxgb4: Initialize data structures before using.
Date: Wed, 7 Nov 2012 16:42:09 +0530
Message-ID: <CANX6Dak5pFutKVn7hV_8-tYx4h67-gS2ud=CrArN--9e=ica5Q@mail.gmail.com>
References: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	divy@chelsio.com, dm@chelsio.com, Jay Hernandez <jay@chelsio.com>
To: Vipul Pandya <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:42411 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2KGLMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 06:12:10 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so1436514obb.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 03:12:09 -0800 (PST)
In-Reply-To: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Nov 6, 2012 at 7:07 PM, Vipul Pandya <vipul@chelsio.com> wrote:
>
> We should not assume reserve fields to be don't cares as fields may change.
> Clearing data structures before using.
>
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index 32eec15..01fa5b7 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -2519,6 +2519,7 @@ int t4_fw_bye(struct adapter *adap, unsigned int mbox)
>  {
>         struct fw_bye_cmd c;
>
> +       memset(&c, 0, sizeof(c));

struct fw_byte_cmd c = {0};

Isn't it better ?

Thanks,
Viral
