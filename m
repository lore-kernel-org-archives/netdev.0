From: Con Kolivas <kernel@kolivas.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 07 Dec 2004 10:56:58 +1100
Message-ID: <cone.1102377418.20012.4626.502@pc.kolivas.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David =?ISO-8859-1?B?Uy4=?= Miller <davem@davemloft.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Karsten Desler <kdesler@soohrt.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Karsten Desler writes:

> * David S. Miller wrote:
>> It's spending nearly half of it's time in iptables.
>> Try to consolidate your rules if possible.  This is the
>> part of netfilter that really doesn't scale well at all.
>> 
> 
> Removing the iptables rules helps reducing the load a little, but the
> majority of time is still spent somewhere else.

I had a similar scenario recently with a very low spec box and found it to 
be the QoS. Disabling traffic shaping and removing the QoS modules made it 
much faster. I don't know if you're using them but it's worth pointing out.

Cheers,
Con
