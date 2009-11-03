From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Support specifying the network namespace upon device creation.
Date: Tue, 03 Nov 2009 01:50:23 -0800
Message-ID: <m1ws28ey3k.fsf@fess.ebiederm.org>
References: <m1eioggeux.fsf@fess.ebiederm.org> <4AEFF7BB.4090301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54766 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbZKCJuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:50:22 -0500
In-Reply-To: <4AEFF7BB.4090301@gmail.com> (Eric Dumazet's message of "Tue\, 03 Nov 2009 10\:28\:27 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> Very nice, with only one long line you could wrap differently.

Say again?  Was that very nice with respect to the rest of the patch?
Or sarcasm because I overlooked this wrap at 80 columns
opportunity in ipgre?

Eric
>   
>> -static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[],
>> +static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
>>  			 struct nlattr *data[])
>>  {
>>  	struct ip_tunnel *nt;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
