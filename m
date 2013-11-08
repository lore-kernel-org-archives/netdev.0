From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Fri, 08 Nov 2013 12:20:30 -0800
Message-ID: <527D478E.4020607@gmail.com>
References: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>	 <527C877D.3080309@gmail.com> <1383913124.9412.223.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:52755 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521Ab3KHUUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:20:19 -0500
Received: by mail-oa0-f43.google.com with SMTP id g12so1293149oah.30
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 12:20:19 -0800 (PST)
In-Reply-To: <1383913124.9412.223.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/2013 4:18 AM, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 22:41 -0800, Sridhar Samudrala wrote:
>
>> Does this fix also help vxlan performance between 2 VMs on 2 different
>> physical m/cs across 10G NIC?
>> What is the throughput you are seeing via 10G nics?
>> With linux 3.12, i am only seeing around 2Gbps (iperf TCP_STREAM with
>> 16K messages)  between 2 VMs when using vxlan across a 10G nic.
>> Is this due to the overhead of software GSO and not doing GRO at the
>> receiver?
> What NIC is used at sender, what NIC is used at receiver ?
I am seeing almost similar results with both Emulex and Intel 10Gb NICs 
at both sender and receiver.
>
> If you use GRE instead of VXLAN, do you get any difference in speed ?
With GRE, i am seeing slightly better results. 3.2Gb/s compared to 
1.8Gb/s with vxlan.


Thanks
Sridhar
