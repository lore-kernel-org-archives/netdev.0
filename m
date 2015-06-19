From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 19 Jun 2015 19:39:07 +0100
Message-ID: <558461CB.3020408@brocade.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com> <558431C3.5020703@cumulusnetworks.com> <5584507C.2000303@brocade.com> <5584609C.5020802@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <tgraf@suug.ch>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:57667 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568AbbFSSjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 14:39:24 -0400
In-Reply-To: <5584609C.5020802@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 19:34, roopa wrote:
> On 6/19/15, 10:25 AM, Robert Shearman wrote:
>> n 19/06/15 16:14, roopa wrote:
>>> Today lwtunnel_skb_lwstate is called from lwtunnel_output which is only
>>> called from ipv4 code.
>>> And my ipv6 variant code was supposed to have a 6 suffix. something like
>>> lwtunnel_output6.
>>> Or to be more explicit i will probably have variants of the output and
>>> skb handling functions like,
>>> lwtunnel_output_ipv4 and lwtunnel_output_ipv6.
>>
>> Do you intend for these functions to be used by netdevices to support
>> the vxlan use case?
>>
>> If so, then how will the netdevice know which one of the two to call?
>> Will there have to be a netdevice for ipv4 and a netdevice for ipv6?
>>
>> If not, could you outline how you intend for it to be implemented?
>
> In the netdevice case, this output function is not called atall. It
> should just follow the existing netdevice the route is pointing to.

Sorry for not being clear, but I meant that there would have to be 
lwtunnel_skb_lwstate functions for ipv4 and ipv6 to match the output 
functions. So in the vxlan use case where it's using a netdevice, how 
would it determine which one to call?

Thanks,
Rob
