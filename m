From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Prevent destroying via RTM_DELTFILTER while classifying
Date: Fri, 10 Dec 2004 13:29:57 +0100
Message-ID: <20041210122957.GU1371@postel.suug.ch>
References: <20041210014322.GS1371@postel.suug.ch> <41B9050A.1060401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41B9050A.1060401@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >The second path needs the spinlock to avoid destroying while
> >a classification is in progress. 2.4 probably needs the same fix,
> >I will cook one up if so.
> > 
> >
> This is not correct. The classifier is unlinked in tc_ctl_tfilter
> before it is destroyed, so it is not visible for classification anymore.

You're right. Thanks.
