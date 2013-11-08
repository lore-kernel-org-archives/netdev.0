From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Fri, 08 Nov 2013 04:18:44 -0800
Message-ID: <1383913124.9412.223.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
	 <527C877D.3080309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56473 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3KHMSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:18:47 -0500
Received: by mail-pd0-f169.google.com with SMTP id q10so2081240pdj.28
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 04:18:47 -0800 (PST)
In-Reply-To: <527C877D.3080309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 22:41 -0800, Sridhar Samudrala wrote:

> Does this fix also help vxlan performance between 2 VMs on 2 different 
> physical m/cs across 10G NIC?
> What is the throughput you are seeing via 10G nics?
> With linux 3.12, i am only seeing around 2Gbps (iperf TCP_STREAM with 
> 16K messages)  between 2 VMs when using vxlan across a 10G nic.
> Is this due to the overhead of software GSO and not doing GRO at the 
> receiver?

What NIC is used at sender, what NIC is used at receiver ?

If you use GRE instead of VXLAN, do you get any difference in speed ?
