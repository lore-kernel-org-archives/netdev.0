From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCHSET 0/11] PKT_SCHED: overall net/pkt_cls.h and
 net/pkt_sched.h cleanup
Date: Tue, 26 Oct 2004 16:22:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026162229.4641743d.davem@davemloft.net>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 00:21:48 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> This patchset attempts to clean up the mess in net/pkt_sched.h
> and net/pkt_cls.h grown over the last years.
> 
> It introduces net/sch_generic.h containing all generic
> sch/cls bits and act_api.h containing pubic action/policer
> bits.
> 
> The current architecture which is basically to have
> net/pkt_sched.h include net/pkt_cls.h and everyone just
> including net/pkt_sched.h makes it impossible to add
> any generic classifer bits into pkt_cls.h and acted
> just like if we had put it into one big file.
> 
> Tested for nearly a week with various combinations of
> action/policer configurations.

Very nice work, all applied.  Thanks Thomas.
