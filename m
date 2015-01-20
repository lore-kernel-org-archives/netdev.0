From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 04/12] net: flow_table: create a set of common
 headers and actions
Date: Tue, 20 Jan 2015 14:10:45 -0800
Message-ID: <54BED265.3040507@gmail.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150120202752.1741.13810.stgit@nitbit.x32> <20150120205938.GD1854@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:41680 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbbATWLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 17:11:12 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so15698215obc.6
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 14:11:11 -0800 (PST)
In-Reply-To: <20150120205938.GD1854@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2015 12:59 PM, John W. Linville wrote:
> On Tue, Jan 20, 2015 at 12:27:53PM -0800, John Fastabend wrote:
>> This adds common headers and actions that drivers can use.
>>
>> I have not yet moved the header graphs into the common header
>> because I'm not entirely convinced its re-usable. The devices
>> I have been looking at have different enough header graphs that
>> they wouldn't be re-usable. However possibly many 40Gbp NICs
>> for example could share a common header graph. When we get
>> multiple implementations we can move this into the common file
>> if it makes sense.
>>
>> And table structures seem to be unique enough that there is
>> little value in putting each devices table layout into the
>> common file so its left for device specific implementation.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   include/linux/if_flow_common.h |  257 ++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 257 insertions(+)
>>   create mode 100644 include/linux/if_flow_common.h
>>
>> diff --git a/include/linux/if_flow_common.h b/include/linux/if_flow_common.h
>> new file mode 100644
>> index 0000000..ef2d66f
>> --- /dev/null
>> +++ b/include/linux/if_flow_common.h
>
> <snip>
>
>> +struct net_flow_action net_flow_pop_vlan = {
>> +	.name = "pop_vlan",
>> +	.uid = ACTION_POP_VLAN,
>> +	.args = net_flow_null_args,
>> +};
>
> Random thought, should there be a "push_vlan" (for double VLAN tagging)?
>
>

Yep I should add that one there are also some other actions
on my todo list but some of them require updates to the driver.

Assuming its not a big issue for anyone I would like like to
get this series in with the match/actions it has and then extend
the action and match lists.

.John

-- 
John Fastabend         Intel Corporation
