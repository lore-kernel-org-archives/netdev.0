From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH] bridge: dont send notification when skb->len == 0 in
 rtnl_bridge_notify
Date: Wed, 28 Jan 2015 06:01:52 -0800
Message-ID: <54C8EBD0.4090502@cumulusnetworks.com>
References: <1422423984-29743-1-git-send-email-roopa@cumulusnetworks.com> <20150127.230511.1131199235284204820.davem@davemloft.net> <54C8E62C.5040603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	rami.rosen@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:45459 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965438AbbA2C4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 21:56:16 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so28211417iec.7
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 18:56:15 -0800 (PST)
In-Reply-To: <54C8E62C.5040603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/28/15, 5:37 AM, roopa wrote:
> On 1/27/15, 11:05 PM, David Miller wrote:
>> From: roopa@cumulusnetworks.com
>> Date: Tue, 27 Jan 2015 21:46:24 -0800
>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> Reported in: https://bugzilla.kernel.org/show_bug.cgi?id=92081
>>>
>>> This patch avoids calling rtnl_notify if the device ndo_bridge_getlink
>>> handler does not return any bytes in the skb.
>>>
>>> Alternately, the skb->len check can be moved inside rtnl_notify.
>>>
>>> For the bridge vlan case described in 92081, there is also a fix needed
>>> in bridge driver to generate a proper notification. Will fix that in
>>> subsequent patch.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> This doesn't apply to the 'net' tree, is there something I missed?
> sorry, that's me. This should be net-next. Resubmitting with net-next 
> in the PATCH line.
>
A few more details ...
....This bug exists in 'net' tree (and I believe previous releases) as 
well.
However my patch was generated on net-next, And there are other changes 
in the related area in net-next tree hence the patch will not apply on 
'net'.
Looks like its better for me to regenerate and submit against 'net'.  
will do.

Thanks,
Roopa
