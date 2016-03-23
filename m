From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH] net: Fix typos and whitespace.
Date: Wed, 23 Mar 2016 19:16:42 +0200
Message-ID: <56F2CF7A.9070104@cloudius-systems.com>
References: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
 <20160323135535.GA18845@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bjorn Helgaas <helgaas@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37178 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbcCWRQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:16:46 -0400
Received: by mail-wm0-f45.google.com with SMTP id p65so33215978wmp.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:16:45 -0700 (PDT)
In-Reply-To: <20160323135535.GA18845@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/23/2016 03:55 PM, Bjorn Helgaas wrote:
> [+cc Vlad]
>
> On Wed, Mar 23, 2016 at 08:45:30AM -0500, Bjorn Helgaas wrote:
>> Fix typos.  Capitalize CPU, NAPI, RCU consistently.  Align structure
>> indentation.  No functional change intended; only comment and whitespace
>> changes.
>>
>> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>> ---
>>   include/linux/netdevice.h |  215 ++++++++++++++++++++++-----------------------
>> @@ -920,7 +920,7 @@ struct tc_to_netdev {
>>    *
>>    *      Enable or disable the VF ability to query its RSS Redirection Table and
>>    *      Hash Key. This is needed since on some devices VF share this information
>> - *      with PF and querying it may adduce a theoretical security risk.
>> + *      with PF and querying it may introduce a theoretical security risk.
>>    * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting)
> Most of these are obvious typo fixes, but I want to point out this one
> in particular because "adduce" is a real word.  It's possible that's
> what Vlad intended in 01a3d796813d ("if_link: Add an additional
> parameter to ifla_vf_info for RSS querying"), though it doesn't quite
> seem to fit.  Vlad, if you did intend "adduce", my apologies in
> advance.

Of course it was a typo :D
Thanks for fixing it, Bjorn.

>
> Bjorn
