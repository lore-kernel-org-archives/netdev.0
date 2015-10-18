From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: wireless: rt2x00: statics code style
Date: Sun, 18 Oct 2015 16:16:21 +0300
Message-ID: <56239BA5.9080806@cogentembedded.com>
References: <1445113533-28116-1-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul McQuade <paulmcquad@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35025 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbJRNQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 09:16:23 -0400
Received: by lffy185 with SMTP id y185so95917139lff.2
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 06:16:21 -0700 (PDT)
In-Reply-To: <1445113533-28116-1-git-send-email-paulmcquad@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/17/2015 11:25 PM, Paul McQuade wrote:

> Do not initialise statics to 0 or NULL
> Also use tabs where possible
>
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
> ---
>   drivers/net/wireless/rt2x00/rt61pci.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
> index c0e730e..53bd23d 100644
> --- a/drivers/net/wireless/rt2x00/rt61pci.c
> +++ b/drivers/net/wireless/rt2x00/rt61pci.c
> @@ -39,7 +39,7 @@
>   /*
>    * Allow hardware encryption to be disabled.
>    */
> -static bool modparam_nohwcrypt = false;
> +static bool modparam_nohwcrypt;
>   module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
>   MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
>
> @@ -1388,7 +1388,7 @@ static bool rt61pci_get_entry_state(struct queue_entry *entry)
>   		rt2x00_desc_read(entry_priv->desc, 0, &word);
>
>   		return (rt2x00_get_field32(word, TXD_W0_OWNER_NIC) ||
> -		        rt2x00_get_field32(word, TXD_W0_VALID));
> +		rt2x00_get_field32(word, TXD_W0_VALID));

    This line should indented more, like it was before. And the outer parens 
aren't needed.

MBR, Sergei
