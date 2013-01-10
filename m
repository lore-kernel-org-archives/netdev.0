From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Thu, 10 Jan 2013 11:28:07 -0800
Message-ID: <CALnjE+p1=+sOAHkndaXGCCm1QPUAfkmgLqrP_8L+8RXnNLvXuw@mail.gmail.com>
References: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
	<20130109.235239.1789560948007134858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:59432 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754824Ab3AJT2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 14:28:08 -0500
Received: by mail-qc0-f198.google.com with SMTP id l35so1595423qco.1
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 11:28:07 -0800 (PST)
In-Reply-To: <20130109.235239.1789560948007134858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 9, 2013 at 11:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Mon,  7 Jan 2013 18:31:32 -0800
>
>> Following patch series restructure GRE and IPIP tunneling code
>> to make it modular. It adds ip_tunnel module which acts as
>> generic tunneling layer which has common code. I have patch
>> to do same for VXLAN too.
>>
>> In Addidtion to restructuring it adds demultiplexer for ipgre
>> protocol, so that linux kernel IPGRE module and OVS gre module
>> can co-exist.
>> Last patch adds linux state updates to tunnel device from
>> lower device.
>
> Please resubmit this when you can also submit the patches which
> actually use this new modularity.
>
> Otherwise the value proposition is impossible to analyze.
>
Ok. These patches are not just modularize ipv4 tunnels but also does
code refactoring, so that there is less code duplication in different
tunneling implementation.

There are couple of independent patches from this patch series. I will
submit them separately. Later I will resubmit modular ip-tunnel
patches as you have suggested.

Thanks,
Pravin.
