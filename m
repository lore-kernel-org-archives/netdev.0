From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/10] netfilter: make /proc/net/netfilter pernet
Date: Wed, 20 Feb 2013 14:36:26 +0800
Message-ID: <51246EEA.5020301@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com> <20130207183318.GA18359@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lve@guap.ru
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:46921 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933283Ab3BTGfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 01:35:44 -0500
In-Reply-To: <20130207183318.GA18359@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,
On 2013/02/08 02:33, Pablo Neira Ayuso wrote:
> Hi Gao,
> 
> Thanks again for improving netns support for netfilter. Comments
> below:
> 
> On Thu, Feb 07, 2013 at 03:49:41PM +0800, Gao feng wrote:
>> Now,only init net has directroy /proc/net/netfilter,
>> this patch make this proc dentry pernet.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  include/net/netns/x_tables.h |  3 +++
>>  net/netfilter/core.c         | 40 ++++++++++++++++++++++++++++++++++------
>>  2 files changed, 37 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
>> index c24060e..aa6a545 100644
>> --- a/include/net/netns/x_tables.h
>> +++ b/include/net/netns/x_tables.h
>> @@ -9,6 +9,9 @@ struct ebt_table;
>>  struct netns_xt {
>>  	struct list_head tables[NFPROTO_NUMPROTO];
>>  	bool notrack_deprecated_warning;
>> +#if defined CONFIG_PROC_FS
>> +	struct proc_dir_entry *proc_netfilter;
>> +#endif
> 
> This doesn't belong here to x_tables, it should be place in
> include/net/net_namespace.h.
> 

Get it,will fix it in next version.
Should I wait for the nf-next being open again?
