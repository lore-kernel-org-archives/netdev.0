From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Bridging woes after 3 days
Date: Mon, 1 Dec 2003 11:33:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201113312.2ce6ec0f.shemminger@osdl.org>
References: <20031123152601.67646dc1.davem@redhat.com>
	<200311290944.PAA27304@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com (David S. Miller), netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anand@eis.iisc.ernet.in (SVR Anand)
In-Reply-To: <200311290944.PAA27304@eis.iisc.ernet.in>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Nov 2003 15:14:08 +0530 (GMT+05:30)
anand@eis.iisc.ernet.in (SVR Anand) wrote:

> Hi,
> 
> After a continous run for 3 days the bridge came down crashing with the
> following kernel panic screen dump. The kernel is 2.6.0-test9-bk25 with
> kernel preemption disabled. 
> 
> The following call stack is what I have seen on the console. The ethernet
> cards are RTL8139. Please let me know if you want more information or finer
> debugging method, I will pass it on when the bridge fails the next time.

Can you hook a serial console to catch the precise wording?

Also if you save copies of /proc/slabinfo on a regular interval (like per hour),
then it is possible to see if there is a memory leak.
