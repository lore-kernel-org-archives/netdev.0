From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 22:52:46 +0300
Message-ID: <20050212195246.GA28895@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <20050212112811.13a0b97d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, rick.jones2@hp.com,
        hubert.tonneau@fullpliant.org, shemminger@osdl.org,
        romieu@fr.zoreil.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050212112811.13a0b97d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> It is correct.  Although, I am still believing that setting PSH
> is the avenue of investigation.

Exactly. That's why the next test should be with disabled TSO in 2.6.9.
If too rare PSHs were a problem, it will show as the same disaster there.

[ And, to be honest, in this case, I daresay MacOS X may be left with its bugs
  alone. Or we could help it with something like setting PSH when we are in slow
  start and each half of CWND after completion of slow start. Or just set
  PSH on each frame. ]

Alexey
