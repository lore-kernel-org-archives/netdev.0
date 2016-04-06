From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next] net: add the AF_KCM entries to family name
 tables
Date: Wed, 6 Apr 2016 10:46:17 +0000
Message-ID: <BLUPR03MB14109AB6475CBB8A59C9D7DBBF9F0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1459867271-14592-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Tom Herbert <tom@herbertland.com>
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0117.outbound.protection.outlook.com ([157.56.111.117]:46448
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750788AbcDFKqU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 06:46:20 -0400
In-Reply-To: <1459867271-14592-1-git-send-email-decui@microsoft.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Dexuan Cui
> Sent: Tuesday, April 5, 2016 22:41
> To: davem@davemloft.net; netdev@vger.kernel.org
> Subject: [PATCH net-next] net: add the AF_KCM entries to family name tables
> 
> This is for the recent kcm driver, which introduces AF_KCM(41) in
> b7ac4eb(kcm: Kernel Connection Multiplexor module).
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/core/sock.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index b67b9ae..7e73c26 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -221,7 +221,8 @@ static const char *const
> af_family_key_strings[AF_MAX+1] = {
>    "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
>    "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
>    "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
> -  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
> +  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_KCM"      ,
> +  "sk_lock-AF_MAX"
>  };
>  static const char *const af_family_slock_key_strings[AF_MAX+1] = {
>    "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
> @@ -237,7 +238,8 @@ static const char *const
> af_family_slock_key_strings[AF_MAX+1] = {
>    "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
>    "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
>    "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
> -  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
> +  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_KCM"       ,
> +  "slock-AF_MAX"
>  };
>  static const char *const af_family_clock_key_strings[AF_MAX+1] = {
>    "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
> @@ -253,7 +255,8 @@ static const char *const
> af_family_clock_key_strings[AF_MAX+1] = {
>    "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
>    "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
>    "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
> -  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
> +  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
> +  "clock-AF_MAX"
>  };
> 
>  /*

Added Tom to Cc.

Thanks,
-- Dexuan
