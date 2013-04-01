From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers/isdn/divert: beautify code, delete useless 'break'
Date: Mon, 01 Apr 2013 18:04:17 +0400
Message-ID: <515993E1.5010508@cogentembedded.com>
References: <5158E854.7060902@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	'Jiri Kosina' <trivial@kernel.org>, tilman@imap.cc,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:52371 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab3DAOFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 10:05:20 -0400
Received: by mail-lb0-f171.google.com with SMTP id v10so1948979lbd.2
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 07:05:17 -0700 (PDT)
In-Reply-To: <5158E854.7060902@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-04-2013 5:52, Chen Gang wrote:

>    delete useless break statements.

> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>   drivers/isdn/divert/isdn_divert.c |    2 --
>   1 files changed, 0 insertions(+), 2 deletions(-)

> diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
> index db432e6..76d505e 100644
> --- a/drivers/isdn/divert/isdn_divert.c
> +++ b/drivers/isdn/divert/isdn_divert.c
> @@ -442,7 +442,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
>   		switch (dv->rule.action) {
>   		case DEFLECT_IGNORE:
>   			return (0);
> -			break;
>
>   		case DEFLECT_ALERT:
>   		case DEFLECT_PROCEED:
> @@ -511,7 +510,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
>
>   		default:
>   			return (0); /* ignore call */
> -			break;

    You could have removed stupid () around 0, while at it.

WBR, Sergei
