From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Fri, 22 Jan 2010 18:50:21 -0500
Message-ID: <4B5A39BD.8020305@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local> <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local> <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753509Ab0AVXui@vger.kernel.org>
In-reply-to: <20100122234656.GC3105@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/22/2010 6:46 PM, Jarek Poplawski wrote:
> On Fri, Jan 22, 2010 at 06:25:12PM -0500, Michael Breuer wrote:
>    
>
> You wrote earlier:
>    
>> [...] Also, there is always a dhcp exchange of some sort
>> preceding the event.
>>      
> So, I'm not sure there was "3) Normal DHCP traffic." if the switch
> could drop DHCP packets in some buggy conditions. Anyway, let's try
> the new one with really "3) Normal DHCP traffic.", I hope.
>
> Jarek P.
>    
When the packets were dropped, there was a different sequence in the log 
- DISCOVER/OFFER repeated. The "normal" is that the sequence appeared 
correct and complete - DISCOVER/OFFER/REQUEST/ACK - or INFORM/ACK (vs. 
INFORM repeatedly sans ACK) as the case may be.
