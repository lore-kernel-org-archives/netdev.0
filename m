From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [pve-devel] bridge vlan range, kernel 4.1 : "message truncated"
 warning when too much vlans defined
Date: Thu, 10 Sep 2015 17:02:51 -0700
Message-ID: <55F21A2B.6070205@cumulusnetworks.com>
References: <999679133.23642075.1438234304221.JavaMail.zimbra@oxygem.tv> <972878625.39892449.1441867226052.JavaMail.zimbra@oxygem.tv> <55F20396.9090505@cumulusnetworks.com> <20150910.155830.1391952981935838143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: aderumier@odiso.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	rami.rosen@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36460 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbIKACw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 20:02:52 -0400
Received: by padhk3 with SMTP id hk3so56648043pad.3
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 17:02:52 -0700 (PDT)
In-Reply-To: <20150910.155830.1391952981935838143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/15, 3:58 PM, David Miller wrote:
> From: roopa <roopa@cumulusnetworks.com>
> Date: Thu, 10 Sep 2015 15:26:30 -0700
>
>> On 9/9/15, 11:40 PM, Alexandre DERUMIER wrote:
>>> Hi,
>>>
>>> This still not fixed in iproute 4.2.
>>>
>>> Is they any plan to increase the rtnl_dump_filter buffer size soon ?
>> Instead of increasing the default size, it would be nicer if this was
>> configurable for iproute2 (I haven't looked yet).
> I would definitely prefer this be done in a run-time manner of some
> sort, and then other libraries can use iproute2's logic as a reference
> for how to deal with this reliably, properly, and in a %100
> future-proof manner.
>
> Something of the "if request X fails, double the buffer size" variety.
agreed. This would be ideal. libnl already handles it this way.
We have to move iproute2 recv buffer to dynamic allocation and also 
realloc on MSG_TRUNC.

I can get to it one of these days unless somebody beats me to it.

thanks.
