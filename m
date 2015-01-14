From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 15:54:36 -0800
Message-ID: <54B701BC.4090209@cumulusnetworks.com>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:51651 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbbANXyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 18:54:37 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so12674657pdb.8
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 15:54:37 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/15, 3:22 PM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of roopa@cumulusnetworks.com
>> Sent: Tuesday, January 13, 2015 10:49 PM
>> To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com;
>> john.fastabend@gmail.com; tgraf@suug.ch; jhs@mojatatu.com; sfeldma@gmail.com;
>> jiri@resnulli.us
>> Cc: wkok@cumulusnetworks.com
>> Subject: [PATCH net-next] bridge: fix setlink/dellink notifications
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
> [..]
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index d06107d..4ac79ff 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2876,13 +2876,6 @@ static int rtnl_bridge_notify(struct net_device *dev,
>> u16 flags)
> The 'flags' argument was only used for applying the same handling of
> MASTER/SELF flags to notification as used for setlink/delink.
> This patch eliminates the MASTER case and leaves only SELF notification.
> It seems clearer to eliminate flags argument and rename the function to
> something like rtnl_bridge_self_notify().
sure, if that makes it clearer.

Thanks,
Roopa
