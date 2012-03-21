From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V1 6/6] IB/rdma_cm: TOS <=> UP mapping for IBoE
Date: Wed, 21 Mar 2012 15:26:35 +0200
Message-ID: <4F69D70B.9090809@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>  <1332321903-11704-7-git-send-email-amirv@mellanox.com> <1332324196.25742.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Sean Hefty <sean.hefty@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:45141 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753934Ab2CUN0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 09:26:55 -0400
In-Reply-To: <1332324196.25742.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/21/2012 12:03 PM, Eric Dumazet wrote:
> Le mercredi 21 mars 2012 =C3=A0 11:25 +0200, Amir Vadai a =C3=A9crit =
:
>> From: Amir Vadai<amirv@mellanox.co.il>
>>
>> Both tagged traffic and untagged traffic use tc tool mapping.
>> Treat RDMA TOS same as IP TOS when mapping to SL
>>
>> Since IP TOS to priority mapping is not exported, had to borrow the =
code from
>> net/ipv4/route.c
>>
>> Signed-off-by: Amir Vadai<amirv@mellanox.co.il>
>> CC: Sean Hefty<sean.hefty@intel.com>
>>
>> ---
>>
>> We can export IP TOS to priority mapping if the networking maintaine=
rs will say
>> where they want it.
>
> Yes please do so. This makes no sense to duplicate ip_tos2prio[]
>

Ok, I will add a patch to export ip_tos2prio, and will use in the code
rt_tos2priority().

- Amir
