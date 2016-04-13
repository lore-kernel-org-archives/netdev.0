From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Wed, 13 Apr 2016 08:11:48 -0400
Message-ID: <570E3784.9010809@mojatatu.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
 <20160410081650.GB22873@pox.localdomain> <570A9B4D.80104@cumulusnetworks.com>
 <570C7133.8070109@cumulusnetworks.com>
 <20160412132151.GA16560@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>, roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36315 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbcDMMLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 08:11:51 -0400
Received: by mail-io0-f177.google.com with SMTP id u185so66925263iod.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 05:11:51 -0700 (PDT)
In-Reply-To: <20160412132151.GA16560@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-12 09:21 AM, Thomas Graf wrote:
> On 04/11/16 at 08:53pm, roopa wrote:
>> Top level stats attributes can be netdev or global attributes: We can include string "LINK" in
>> the names of all stats belonging to a netdev to make it easier to recognize the netdev stats (example):
>>   IFLA_STATS_LINK64,           (netdev)
>>   IFLA_STATS_LINK_INET6,    (netdev)
>>   IFLA_STATS_TCP,                (non-netdev, global tcp stats)
>
> This is fine as well. It means that we cant mix netdev and non-netdev
> stats or stats for multiple netdevs in the same request which would
> not be the case if you nest it and have a top level attribute which
> is a list of requests. That may be borderline to overengineering
> though so I'm fine this as well.


Well - using a subheader which has ifindex on it for non-netdev stats
seems wrong then.

cheers,
jamal
