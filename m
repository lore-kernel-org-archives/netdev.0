From: Martin Pool <mbp@sourcefrog.net>
Subject: Re: Sockets hang in FIN_WAIT1 state in linux 2.2.5
Date: Sat, 11 Jun 2005 12:03:48 +1000
Message-ID: <20050611020348.GA27334@sourcefrog.net>
References: <20050610105808.13626.qmail@web30909.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavan K <pavankrishnamurthy@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050610105808.13626.qmail@web30909.mail.mud.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 10 Jun 2005, Pavan K <pavankrishnamurthy@yahoo.com> wrote:
> Hi,
> This is Pavan from India, a s/w engineer stuck in a TCP problem. We have a
> legendary linux 2.2.5 kernel (redhat ) system which cant be replaced in my
> company. I have noticed that my server stops ACK ing the SYN packets after some
> time . Also when i netstat i can see lots of sockets hung in FIN_WAIT1 state.
> Upon googling, I found ur mails in the mailing list. Sounds that you too had
> similar problems.
> So please suggest me any solution to this problem if you have. I am in a
> critical stage to fix this bug. I cant upgrade my system to newer kernel since
> it needs lot of code porting.

I've heard similar reports from people running distcc on 2.2 kernels;
after a long time the machine stops accepting new connections.  If you
can't upgrade the kernel your options are very limited: either work
out the precise patch, or reboot your machines regularly.  The second
is probably easier.

-- 
Martin
