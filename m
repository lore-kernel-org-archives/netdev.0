From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 16:01:32 +0100
Message-ID: <47EBB6CC.1000102@trash.net>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080326.234049.256533912.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> Date: Thu, 27 Mar 2008 08:35:06 +0200
> 
>> It seems i am having very bad luck with 2.6.27. As Linus told, it have to be 
>> released soon, but it is crashing like hell on high network load.
> 
> That's amazing, you've taken a trip into the future and are running
> 2.6.27 already, please let me borrow your time machine :-)
> 
> More seriously, there is obviously something very unique to your
> setup or else everyone would be reporting this crash, and we have
> to find out what that might be.
> 
> There seems to be bunch of netfilter stuff in your traces, but
> the top of the trace is somewhere totally unrelated.  This is
> a common reoccurance in your crash traces, making them less
> useful than they could be.
> 
> I know you asked before what can be done to improve the traces,
> but I'm not an x86 expert so I have no idea how to help you
> in that area.
> 
> Patrick, could you see if you can make any sense of his log?
> I see conttrack a lot in the backtraces.


The conntrack stuff looks harmless, I went through the code just
to make sure, but I can't see anything wrong there.
