From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RESEND PATCH net-next] xfrm: add LINUX_MIB_XFRMACQUIREERROR
 statistic counter
Date: Mon, 20 May 2013 18:11:38 +0400
Message-ID: <519A2F1A.3010703@cogentembedded.com>
References: <1369014025-19564-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:58627 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073Ab3ETOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 10:11:42 -0400
Received: by mail-la0-f43.google.com with SMTP id ez20so5194167lab.2
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 07:11:40 -0700 (PDT)
In-Reply-To: <1369014025-19564-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-05-2013 5:40, Fan Du wrote:

> When host ping its peer, ICMP echo request packet triggers IPsec
> policy, then host negotiates SA secret with its peer. After IKE
> installed SA for OUT direction, but before SA for IN direction
> installed, host get ICMP echo reply from its peer. At the time
> being, the SA state for IN direction could be XFRM_STATE_ACQ,
> then the received packet will be dropped after adding
> LINUX_MIB_XFRMINSTATEINVALID statistic.

> Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
> scenario when SA in larval state is much clearer for user than
> LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
> bad.

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   include/uapi/linux/snmp.h |    1 +
>   net/xfrm/xfrm_input.c     |    5 +++++
>   net/xfrm/xfrm_proc.c      |    1 +
>   3 files changed, 7 insertions(+), 0 deletions(-)

> diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
> index df2e8b4..3d072bf 100644
> --- a/include/uapi/linux/snmp.h
> +++ b/include/uapi/linux/snmp.h
> @@ -287,6 +287,7 @@ enum
>   	LINUX_MIB_XFRMOUTPOLERROR,		/* XfrmOutPolError */
>   	LINUX_MIB_XFRMFWDHDRERROR,		/* XfrmFwdHdrError*/
>   	LINUX_MIB_XFRMOUTSTATEINVALID,		/* XfrmOutStateInvalid */
> +	LINUX_MIB_XFRMACQUIREERROR,     /* XfrmAcquireError*/

    Please indent the comment with tabs and align with the above ones.

WBR, Sergei
