From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Tue, 15 Feb 2005 15:25:04 -0800
Message-ID: <20050215152504.5f0b139e.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<420D37A3.6020209@hp.com>
	<20050211170958.17fcde21.davem@davemloft.net>
	<20050212143105.GB27456@yakov.inr.ac.ru>
	<20050212112811.13a0b97d.davem@davemloft.net>
	<20050212195246.GA28895@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, rick.jones2@hp.com, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org, romieu@fr.zoreil.com, netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212195246.GA28895@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 22:52:46 +0300
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Exactly. That's why the next test should be with disabled TSO in 2.6.9.
> If too rare PSHs were a problem, it will show as the same disaster there.
> 
> [ And, to be honest, in this case, I daresay MacOS X may be left with its bugs
>   alone. Or we could help it with something like setting PSH when we are in slow
>   start and each half of CWND after completion of slow start. Or just set
>   PSH on each frame. ]

Setting it every other frame would fix the problem, just forcing it to
miss header prediction path is what is needed to avoid the silly delayed
ACK behavior.  And PSH is one way to do that.
