From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules
 in LOCAL_IN
Date: Fri, 02 Jul 2010 14:35:53 +0200
Message-ID: <4C2DDD29.7030503@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net> <1278064342-19059-2-git-send-email-kaber@trash.net> <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr> <4C2DBCD3.20208@trash.net> <alpine.LSU.2.01.1007021416120.30410@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007021416120.30410@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Friday 2010-07-02 12:17, Patrick McHardy wrote:
>   
>>> I still have not grasped why SNAT is needed in the INPUT path. For the
>>> tunnel scenario that you wanted to build I could not find a reason to
>>> do SNAT in that place - since the non-encapsulated packets don't go
>>> through INPUT anyway.
>>>       
>> Sure they do, if they are destined for the host itself. I'm not sure
>> what's so hard to understand about this patch, you have f.i. multiple
>> tunnels using the same remote network, on INPUT and POSTROUTING you SNAT
>> them to seperate networks based on criteria like the network device or
>> the IPsec tunnel to be able to distinguish them.
>>     
>
> But they are already distinguishable by the ctmark that is applied
> to these connections to do routing of the reply, are they not?
>   

Its not (only) about routing, you simply can't have two connections using
the same identity.
