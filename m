From: DaMouse Networks <damouse@ntlworld.com>
Subject: Re: [patch] 2.6.1-bk1-netdev4 - latent bug
Date: Fri, 16 Jan 2004 16:47:00 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116164700.4670ca1b@EozVul.WORKGROUP>
References: <20040114233350.A4646@electric-eye.fr.zoreil.com>	<20040115003319.B4646@electric-eye.fr.zoreil.com>
	<20040115071314.0141e55c@EozVul.WORKGROUP>
	<20040115090731.B13143@electric-eye.fr.zoreil.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040115090731.B13143@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Organization: DaMouse Networks
X-Mailer: Sylpheed version 0.9.8claws (GTK+ 1.2.10; i686-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

SMP-Enabled Kernel, 
i was pinging my router (Win2k Server) which seems to be pretty good at withstanding ping -f :) and I went downstairs and checked it was still alive after I lost contact, 
hey netdev peeps and peepesses, my computer is still alive and glowing blue :P

-DaMouse

On Thu, 15 Jan 2004 09:07:31 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> DaMouse Networks <damouse@ntlworld.com> :
> [...]
> > --- 192.168.0.1 ping statistics ---
> > 29918 packets transmitted, 16354 received, 45% packet loss, time 290162ms
> > rtt min/avg/max/mdev = 0.379/0.398/10.352/0.181 ms, ipg/ewma 9.698/0.389 ms
> 
> Btw, you can/may lower the packet size during ping (see -s option).
> 
> [...]
> > Then  I try again  and I get this:
> > 
> > PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
> > >From 192.168.0.94 icmp_seq=9 Destination Host Unreachable
> 
> Ok, I'll dig that. It does not seem _too_ bad.
> - is your modem able to stand a ping -f without loss ?
> - were you running an smp-enabled kernel ?
> - can you Cc: netdev so people know that your computer survived ?
> 
> Thanks for the quick feedback.
> 
> --
> Ueimor
