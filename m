From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Re: Next March 25: net/netfilter/xt_LED build failure.
Date: Wed, 25 Mar 2009 15:08:16 +0100
Message-ID: <49CA3AD0.1090601@trash.net>
References: <20090325135759.4397.53055.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050107060906090309050505"
Cc: "David S. Miller" <davem@davemloft.net>,
	Sachin Sant <sachinp@in.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>,
	Adam Nielsen <a.nielsen@shikadi.net>
To: Subrata Modak <tosubrata@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761290AbZCYOIk@vger.kernel.org>
In-Reply-To: <20090325135759.4397.53055.sendpatchset@subratamodak.linux.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050107060906090309050505
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Subrata Modak wrote:
> The following patch will solve the build problem reported by Sachin.
> But would leave the following warnings. I hope we can ignore them:
> 
> net/netfilter/xt_LED.c: In function â��led_timeout_callbackâ��:
> net/netfilter/xt_LED.c:78: warning: unused variable â��ledinternalâ��
> net/netfilter/xt_LED.c: In function â��led_tg_checkâ��:
> net/netfilter/xt_LED.c:87: warning: unused variable â��errâ��
> 
> Signed-Off-By: Subrata Modak<subrata@linux.vnet.ibm.com>
> ---
> 
> --- a/linux-2.6.29/net/netfilter/xt_LED.c	2009-03-25 18:38:08.000000000 +0530
> +++ b/linux-2.6.29/net/netfilter/xt_LED.c	2009-03-25 18:26:55.000000000 +0530
> @@ -99,6 +99,7 @@ static bool led_tg_check(const struct xt
>  
>  	ledinternal->netfilter_led_trigger.name = ledinfo->id;
>  
> +#ifdef CONFIG_LEDS_TRIGGERS
...


Does this patch fix it?

--------------050107060906090309050505
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

ZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvS2NvbmZpZyBiL25ldC9uZXRmaWx0ZXIvS2Nv
bmZpZwppbmRleCAyNTYyZDA1Li4yYzk2N2U0IDEwMDY0NAotLS0gYS9uZXQvbmV0ZmlsdGVy
L0tjb25maWcKKysrIGIvbmV0L25ldGZpbHRlci9LY29uZmlnCkBAIC0zNzQsNyArMzc0LDcg
QEAgY29uZmlnIE5FVEZJTFRFUl9YVF9UQVJHRVRfSEwKIAogY29uZmlnIE5FVEZJTFRFUl9Y
VF9UQVJHRVRfTEVECiAJdHJpc3RhdGUgJyJMRUQiIHRhcmdldCBzdXBwb3J0JwotCWRlcGVu
ZHMgb24gTEVEU19DTEFTUworCWRlcGVuZHMgb24gTEVEU19DTEFTUyAmJiBMRURfVFJJR0dF
UlMKIAlkZXBlbmRzIG9uIE5FVEZJTFRFUl9BRFZBTkNFRAogCWhlbHAKIAkgIFRoaXMgb3B0
aW9uIGFkZHMgYSBgTEVEJyB0YXJnZXQsIHdoaWNoIGFsbG93cyB5b3UgdG8gYmxpbmsgTEVE
cyBpbgo=
--------------050107060906090309050505--
