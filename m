From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] Rename struct net to struct netns
Date: Mon, 17 Sep 2007 16:59:26 +0200
Message-ID: <46EE964E.7050901@fr.ibm.com>
References: <46EE932F.2030206@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:36193 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbXIQPCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 11:02:07 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8HF26vS028412
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 15:02:06 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HF26sx2359370
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 16:02:06 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HF1ntS005226
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 16:01:49 +0100
In-Reply-To: <46EE932F.2030206@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> The name struct net is too generic. There already were
> some people who wanted to have some better name (for
> easier grep for example). I propose the struct netns one.
> 
> The patch is (already) huge (sorry), but it's nothing but
>   sed -e s/struct net\>/struct netns/g
> 
> If this name is bad as well, let's select a new one
> before the struct net floods the kernel.

[ SNIP ]

> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -29,7 +29,7 @@ struct nsproxy {
>  	struct mnt_namespace *mnt_ns;
>  	struct pid_namespace *pid_ns;
>  	struct user_namespace *user_ns;
> -	struct net 	     *net_ns;
> +	struct netns 	     *net_ns;

IMHO, if we want to be consistent with all the rest of the namespaces, 
that should be net_namespace.

[ SNIP ]
