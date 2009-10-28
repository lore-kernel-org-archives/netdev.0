From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 3/3] net: TCP thin dupack
Date: Tue, 27 Oct 2009 22:43:16 -0400
Message-ID: <4AE7AFC4.3040805@gmail.com>
References: <4AE7207D.8090402@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757199AbZJ1CnR@vger.kernel.org>
In-Reply-To: <4AE7207D.8090402@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Petlund wrote:
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index e64368d..f4a05ff 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -97,6 +97,7 @@ enum {
>  #define TCP_CONGESTION		13	/* Congestion control algorithm */
>  #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
>  #define TCP_THIN_RM_EXPB        15      /* Remove exp. backoff for thin streams*/
> +#define TCP_THIN_DUPACK         16      /* Fast retrans. after 1 dupack */
>  
I've not had the chance to examine the rest, but I've been poking at a
patch series that's used 15 for over a year, so could you try 16 and 17?
