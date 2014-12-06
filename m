From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Fri, 05 Dec 2014 23:46:23 -0800
Message-ID: <5482B44F.2050509@cumulusnetworks.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <20141205224320.GA22992@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47139 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaLFHqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 02:46:30 -0500
In-Reply-To: <20141205224320.GA22992@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/14, 2:43 PM, Thomas Graf wrote:
> On 12/04/14 at 06:26pm, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is a generic high level feature flag for all switch asic features today.
>>
>> switch drivers set this flag on switch ports. Logical devices like
>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>
>> I had to use SWITCH in the name to avoid ambiguity with other feature
>> flags. But, since i have been harping about not calling it 'switch',
>> I am welcome to any suggestions :)
>>
>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>> in net_device_flags.
> What does this flag indicate specifically? What driver would
> implement ndo_bridge_setlink() but not set this flag?
>
> I think it should be clearly documented when this flag is to bet set.
I mentioned it as an alternative because it was there in my RFC patch. 
There is no code for it yet.
And I will get rid of the comment in v2.
