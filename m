From: William Manley <william.manley@youview.com>
Subject: Re: [PATCH v3 2/2] net: igmp: Allow user-space configuration of igmp
 unsolicited report interval
Date: Wed, 31 Jul 2013 10:47:19 +0100
Message-ID: <51F8DD27.7000305@youview.com>
References: <1375107711-9029-1-git-send-email-william.manley@youview.com> <1375107711-9029-2-git-send-email-william.manley@youview.com> <20130730061426.GF2490@order.stressinduktion.org> <20130730.165557.1185057462473078021.davem@davemloft.net> <20130731063442.GA10498@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<bcrl@kvack.org>, <luky-37@hotmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:51885
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750775Ab3GaJry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 05:47:54 -0400
In-Reply-To: <20130731063442.GA10498@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/07/13 07:34, Hannes Frederic Sowa wrote:
> On Tue, Jul 30, 2013 at 04:55:57PM -0700, David Miller wrote:
>> From: Hannes Frederic Sowa<hannes@stressinduktion.org>
>> Date: Tue, 30 Jul 2013 08:14:26 +0200
>>
>>> On Mon, Jul 29, 2013 at 03:21:51PM +0100, William Manley wrote:
>>>> @@ -2099,6 +2103,10 @@ static struct devinet_sysctl_table {
>>>>   		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
>>>>   		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
>>>>   					      "force_igmp_version"),
>>>> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV2_UNSOLICITED_REPORT_INTERVAL,
>>>> +					      "igmpv2_unsolicited_report_interval"),
>>>> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
>>>> +					      "igmpv3_unsolicited_report_interval"),
>>>>   		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
>>>>   					      "promote_secondaries"),
>>>>   		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
>>>
>>> Why did you use DEVINET_SYSCTL_FLUSHING_ENTRY here? Wouldn't
>>> DEVINET_SYSCTL_RW_ENTRY be a better choice?
>>
>> Agreed, there is no reason to flush the routing cache just because
>> the igmp unsolicited report interval changed.
>
> William, could you convert force_igmp_version to DEVINET_SYSCTL_RW_ENTRY as
> well when you send a new patch?

Will do.  I have to confess I only made it flushing because I was 
copying force_igmp_version without understanding.

Will take a couple of days as I have a bunch of other stuff on ATM.

Thanks

Will
