From: Rick Jones <rick.jones2@hp.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 09:49:10 -0700
Message-ID: <48B58586.3080806@hp.com>
References: <200808220457.40892.denys@visp.net.lb>	<20080826201406.GA24827@2ka.mipt.ru>	<48B46B48.7030609@cosmosbay.com>	<20080826205158.GA15266@2ka.mipt.ru>	<87vdxmr53f.fsf@basil.nowhere.org> <48B57BD3.5050206@hp.com> <20080827162735.GW26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756429AbYH0Qt3@vger.kernel.org>
In-Reply-To: <20080827162735.GW26610@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>Those banks really want to crank down on latency - to the point they 
>>start disabling interrupt coalescing.  I bet they'd toss anything out 
>>they could to shave another microsecond.
> 
> 
> This change would actually likely lower their latency.

I'm guessing you mean increase their latency?  I agree, it could - 
depends entirely on the PPS in production I suspect.

rick jones

ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt

I should probably refresh/update that one of these days
