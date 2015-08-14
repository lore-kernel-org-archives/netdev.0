From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] utils: add missing return value
Date: Thu, 13 Aug 2015 19:42:08 -0700
Message-ID: <20150813194208.3966682f@urahara>
References: <1439516180-19076-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36012 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbbHNCl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 22:41:59 -0400
Received: by pdco4 with SMTP id o4so26308653pdc.3
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 19:41:58 -0700 (PDT)
In-Reply-To: <1439516180-19076-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2015 01:36:20 +0000
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Add missing return value to fix warnings
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  include/utils.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/utils.h b/include/utils.h
> index 95d162c..0c57ccd 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -137,7 +137,7 @@ const char *mpls_ntop(int af, const void *addr, char *str, size_t len);
>  int mpls_pton(int af, const char *src, void *addr);
>  
>  extern int __iproute2_hz_internal;
> -__get_hz(void);
> +int __get_hz(void);
>  
>  static __inline__ int get_hz(void)
>  {

Applied, thanks
