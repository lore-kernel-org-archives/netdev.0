From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Question] SMP for TCP/IP Stack
Date: Wed, 25 Sep 2002 12:32:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D920F38.410CA3AB@us.ibm.com>
References: <20020925112731.A19934@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hyochang Nam <cannon@postech.ac.kr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hyochang Nam wrote:
> 
> Can Linux Kernel 2.4.X handle two IP Packets at the same time
> in a SMP machine which has two CPUs?

We've done tests on large SMP's without significant problems.

> I have a SMP machine which equips two Intel Xeon CPUs and two
> Intel Gigabit Network Cards. When I sent small IP Packets
> to the machine, most of packets are dropped. When I watch

How small is your small packet? Do you have the same problem
with larger packets? 
Are these drops showing up in ifconfig output? i.e. reported
by the card? In which case I suspect it might be a card issue.
Also, have you configured your card settings?

> CPU utlization with TOP program, only one CPU shows high value
> but the other shows much low value, ie. 10% CPU utlization.

How are you doing your sends? Is your application mostly running
on one CPU? Do you have anything else running on the busy CPU?
What is the interrupt distribution between the two CPU's?

> My test shows current IP Stack in Linux Kernel cannot provide
> SMP Processing properly. But, some articles said Linux Kernel 2.4
> gives true SMP processing. What do you think my problem is?

Could you provide your stats (ifconfig, netstat -s)?

> Hyochang Nam

thanks,
Nivedita
