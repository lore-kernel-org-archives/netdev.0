From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 1/2] Header rebase for
 IFA_F_MCAUTOJOIN
Date: Sun, 15 Mar 2015 12:42:54 -0700
Message-ID: <20150315124254.28fe5835@urahara>
References: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
	<1425493810-2537-2-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34885 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCOTmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:42:52 -0400
Received: by pdbop1 with SMTP id op1so37174759pdb.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:42:52 -0700 (PDT)
In-Reply-To: <1425493810-2537-2-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Mar 2015 10:30:09 -0800
Madhu Challa <challa@noironetworks.com> wrote:

> ---
>  include/linux/if_addr.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
> index cc375e4..2033adc 100644
> --- a/include/linux/if_addr.h
> +++ b/include/linux/if_addr.h
> @@ -50,6 +50,7 @@ enum {
>  #define IFA_F_PERMANENT		0x80
>  #define IFA_F_MANAGETEMPADDR	0x100
>  #define IFA_F_NOPREFIXROUTE	0x200
> +#define IFA_F_MCAUTOJOIN	0x400
>  
>  struct ifa_cacheinfo {
>  	__u32	ifa_prefered;

Already picked this up in my net-next branch.
