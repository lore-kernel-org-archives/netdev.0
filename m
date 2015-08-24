From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Low throughput in VMs using VxLAN
Date: Mon, 24 Aug 2015 10:27:00 -0700
Message-ID: <55DB53E4.4010105@hp.com>
References: <CAOoYtEtnvYKcs7s0Bmv+7+L0=nhXdJfeC2uSZa8Nz9i_+jy2Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Santosh R <skrastapur@gmail.com>, netdev@vger.kernel.org,
	tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hp.com ([15.240.92.67]:58790 "EHLO
	g9t5009.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbbHXR1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:27:05 -0400
In-Reply-To: <CAOoYtEtnvYKcs7s0Bmv+7+L0=nhXdJfeC2uSZa8Nz9i_+jy2Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 09:19 AM, Santosh R wrote:
>   Hi,
>
>     Earlier I was seeing lower throughput in VMs using VxLan as GRO was
> not happening in VM.
> Tom Herbert suggested to use "vxlan: GRO support at tunnel layer" patch series.
> With today's net-next (4.2.0-rc7) in host and VM, I could see GRO
> happening for vxlan, macvtap and virtual interface in VM.
> The throughput is still low between VMs (around 4Gbps compared to
> 9Gbps without VxLAN).

Out of curiosity, have you tried tweaking gro_flush_timeout 
(gro_flush_interval?) for the VMs eth interface?  Say perhaps a value of 
1000?  (I'm assuming the VM is using virtio_net) Does the behaviour 
change if vhost-net is loaded into the host and used by the VM?

rick jones

For completeness, it would also be good to compare the likes of netperf 
TCP_RR between VxLAN and without.
