From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 19 Jun 2015 11:34:04 -0700
Message-ID: <5584609C.5020802@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com> <558431C3.5020703@cumulusnetworks.com> <5584507C.2000303@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35012 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbFSSeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 14:34:06 -0400
Received: by pdbci14 with SMTP id ci14so37287136pdb.2
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 11:34:06 -0700 (PDT)
In-Reply-To: <5584507C.2000303@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 10:25 AM, Robert Shearman wrote:
> n 19/06/15 16:14, roopa wrote:
>> Today lwtunnel_skb_lwstate is called from lwtunnel_output which is only
>> called from ipv4 code.
>> And my ipv6 variant code was supposed to have a 6 suffix. something like
>> lwtunnel_output6.
>> Or to be more explicit i will probably have variants of the output and
>> skb handling functions like,
>> lwtunnel_output_ipv4 and lwtunnel_output_ipv6.
>
> Do you intend for these functions to be used by netdevices to support 
> the vxlan use case?
>
> If so, then how will the netdevice know which one of the two to call? 
> Will there have to be a netdevice for ipv4 and a netdevice for ipv6?
>
> If not, could you outline how you intend for it to be implemented?

In the netdevice case, this output function is not called atall. It 
should just follow the existing netdevice the route is pointing to.
