From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Thu, 26 Feb 2015 14:43:26 -0800
Message-ID: <CALnjE+pQ9M=4fQNWH0=nqboUAgMzxPYKefBg7ivaW-3Dk4_8Xg@mail.gmail.com>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
	<20141028.144344.398016097830457432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:49227 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753970AbbBZWn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:43:27 -0500
Received: by mail-ie0-f170.google.com with SMTP id rl12so22346604iec.4
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 14:43:26 -0800 (PST)
In-Reply-To: <20141028.144344.398016097830457432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,
This been merged to upstream kernel for a while. Can you send patch to
backport it for ovs-repo?

Thanks,
Pravin.

On Tue, Oct 28, 2014 at 11:43 AM, David Miller <davem@davemloft.net> wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 22 Oct 2014 17:29:06 +0200
>
>> The internal and netdev vport remain part of openvswitch.ko. Encap
>> vports including vxlan, gre, and geneve can be built as separate
>> modules and are loaded on demand. Modules can be unloaded after use.
>> Datapath ports keep a reference to the vport module during their
>> lifetime.
>>
>> Allows to remove the error prone maintenance of the global list
>> vport_ops_list.
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
> Applied, thanks a lot Thomas.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
