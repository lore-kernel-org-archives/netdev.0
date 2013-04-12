From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/7] xen-netfront: frags -> slots in log message
Date: Fri, 12 Apr 2013 18:40:06 +0400
Message-ID: <51681CC6.7070408@cogentembedded.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com> <1365505655-8021-5-git-send-email-wei.liu2@citrix.com> <5164190D.70905@cogentembedded.com> <20130409134745.GI16998@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:37469 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab3DLOlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 10:41:11 -0400
Received: by mail-lb0-f180.google.com with SMTP id t11so2722127lbi.11
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 07:41:10 -0700 (PDT)
In-Reply-To: <20130409134745.GI16998@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-04-2013 17:47, Wei Liu wrote:

>>> Also fix a typo in comment.

>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>> ---
>>>    drivers/net/xen-netfront.c |    4 ++--
>>>    1 file changed, 2 insertions(+), 2 deletions(-)

>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>> index d9097a7..1bb2e20 100644
>>> --- a/drivers/net/xen-netfront.c
>>> +++ b/drivers/net/xen-netfront.c
>> [...]
>>> @@ -771,7 +771,7 @@ next:
>>>
>>>    	if (unlikely(slots > max)) {
>>>    		if (net_ratelimit())
>>> -			dev_warn(dev, "Too many frags\n");
>>> +			dev_warn(dev, "Too many slots\n");
>>
>>      Shouldn't you have done this change as a part of patch #2?

> Because patch 2 has been applied to David Miller's tree, this is an
> incremental patch on top of that.

    Why are you reposting already applied patch over and over again then?

> Wei.

WBR, Sergei
