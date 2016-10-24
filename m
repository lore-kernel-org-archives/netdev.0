From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Redundancy support through HSR and PRP
Date: Mon, 24 Oct 2016 12:35:32 -0400
Message-ID: <580E3854.4030009@ti.com>
References: <57FBDF33.1060606@ti.com> <5808F9FC.1080802@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:34749 "EHLO arroyo.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756345AbcJXQfm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 12:35:42 -0400
In-Reply-To: <5808F9FC.1080802@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2016 01:08 PM, Murali Karicheri wrote:
> David,
> 
> On 10/10/2016 02:34 PM, Murali Karicheri wrote:
>> All,
>>
>> Wondering if there plan to add PRP driver support, like HSR in Linux? AFAIK, PRP
>> adds trailor to Ethernet frame and is used for Redundancy management like HSR.
>> So wondering why this is not supported.
>>
>> Thanks
>>
> I need to work on a prp driver for Linux. So if there is already someone working
> on this, I would like to join and contribute. Either way please respond so that
> I can work to add this support. 
> 
> I am also working to add support for offload HSR functions to hardware and will
> need to modify the hsr driver to support the same. So any suggestion as to how this
> can be done, will be appreciated.
> 
> Here is what I believe should happen to support this at a higher level
> 
> hsr capable NIC (with firmware support) may able to
>  - duplicate packets at the egress. So only one copy needs to be forwarded to the
>    NIC
>  - Discard the duplicate at the ingress. So forward only one to copy to the ethernet
>    driver
>  - Manage supervision of the network. Keep node list and their status
> 
> It could be a subset of the above. So I am hoping this can be published by the Ethernet
> driver as a set of features. The hsr driver can then look at this features and
> decide to offload and disable same functionality at the hsr driver. Also the node list/status
> has to be polled from the underlying hardware.
> 
> PRP is similar to HSR in many respect. Redundancy management uses a suffix tag to the MAC
> frame instead of prefix used by HSR. So they are more transparently handled by 
> switches or routers. Probably i need to do
>   - rename net/hsr to net/hsr-prp
>   - restructure the current set of files to add prp support 
> 
> Thanks
> 
+ Arvid

Didn't copy HSR owner in my original email. Copying now.


-- 
Murali Karicheri
Linux Kernel, Keystone
