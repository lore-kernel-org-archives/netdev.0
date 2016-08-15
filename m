From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 06:41:14 -0400
Message-ID: <a27a76e8-d7c3-457d-be98-00cf2d942cf8@mojatatu.com>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
 <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
 <20160815132436.0d1e34b6@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amir@vadai.me>, Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36082 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbcHOKlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 06:41:24 -0400
Received: by mail-it0-f65.google.com with SMTP id j124so3160750ith.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 03:41:24 -0700 (PDT)
In-Reply-To: <20160815132436.0d1e34b6@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-15 06:24 AM, Shmulik Ladkani wrote:
> On Mon, 15 Aug 2016 06:08:10 -0400, jhs@mojatatu.com wrote:

>> Assuming $VXLAN is actually not a linux netdev of type vxlan?
>> then the action does vxlan encap redirect sends it to the $VXLAN
>> dev with encapsulation in place.
>
> I assume Amir refers to vxlan netdev in VXLAN_F_COLLECT_METADATA mode,
> using the tun_info metadata found in skb_metadata_dst.
> The action is supposed to assign the tun metadata.
>

I see - so you let the vxlan netdev do the encap?
Would it still scale to a _very large_ number of tunnels?
How many netdevs are you going to use? I am assuming you will hit
a nasty lock somewhere(qdisc?) if you use only one.

cheers,
jamal
