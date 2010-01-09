From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Fri, 08 Jan 2010 23:45:35 -0500
Message-ID: <4B4809EF.1070609@majjas.com>
References: <4B459368.2000503@majjas.com> <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local> <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local> <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local> <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local> <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local> <4B47A81B.5040601@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752521Ab0AIEqL@vger.kernel.org>
In-reply-to: <4B47A81B.5040601@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/8/2010 4:48 PM, Michael Breuer wrote:
> On 1/8/2010 4:29 PM, Jarek Poplawski wrote:
> ...
>> BTW, don't hurry with that yet, but in the next test, please try
>> alternative 2 again (i.e. with MMAP + no DMAR + disable_msi).
>>
> Will do - still up from yesterday... no more dropped packets... none 
> of the dns errors either. To be expected I suppose as long as I'm 
> trying to sniff it. Assuming no immediate erorrs with alt2, no DMAR + 
> disable_msi I'll report back after it's been up for a while.
> -- 
Ok - ran alt1 and alt2, both with MMAP, no DMAR and disable_msi. Both 
seem to behave similarly. No logged errors; large numbers of dropped RX 
packets. One odd thing: when driving every sort of traffic through, I 
was able to hose the client adapter (win7) repeatedly by runnnig the 
win7 backup and connecting Windows Media Player to a Mediatomb stream 
while also running a remote X11 session. Looks like the SSDP traffic 
that occurs at the same time as the SMB traffic and X11 traffic takes 
out the adapter on Win7 - Nforce.
Reran with msi enabled, MMAP and no DMAR. Also no errors; much faster, 
and the Win7 side survives the same conditions that don't work when msi 
is disabled. Doesn't make sense to me, but it is what it is.

Going to leave this up for a while and see if things remain functional.
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
