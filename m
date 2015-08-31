From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] ipv4: fix 32b build
Date: Mon, 31 Aug 2015 18:27:16 +0530
Message-ID: <55E44F2C.7020809@linux.vnet.ibm.com>
References: <1441025167-13740-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:49876 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbbHaMzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 08:55:21 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 31 Aug 2015 18:25:19 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AB8ECE0056
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 18:24:33 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7VCtCXR45482158
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 18:25:12 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7VCtBW1000723
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 18:25:11 +0530
In-Reply-To: <1441025167-13740-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2015 06:16 PM, Madalin Bucur wrote:
> Address remaining issue after 80ec192.
>
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
>   net/ipv4/af_inet.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index c2d0ebc..96773a2 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1496,7 +1496,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
>   	int cpu;
>
>   	for_each_possible_cpu(cpu) {
> -		res += snmp_get_cpu_field(mib, cpu, offt, syncp_offset);
> +		res += snmp_get_cpu_field64(mib, cpu, offt, syncp_offset);
>   	}
>   	return res;
>   }


Thanks Madlin for catching this for 32bit.
