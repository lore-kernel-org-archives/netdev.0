From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in action
 policer
Date: Mon, 20 Dec 2004 15:51:34 -0800
Message-ID: <20041220155134.580396cb.davem@davemloft.net>
References: <20041215130128.GK8493@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041215130128.GK8493@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 14:01:28 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> This should go in before 2.6.10. It fixes a forgotten case to provide
> police backward compatibility statistics for old iproute2 versions
> running on a new kernel with actions enabled. Should make distributions
> happy with older iproute2 versions and all-included kernel configs
> since they probably favour actions over plain policer.

Applied, thanks Thomas.

About testsuites.  Figure out what we want, and I can even put up a
BK repository for the testsuite on kernel.bkbits.net  Unlike what
some others appear to be suggesting, I see no problem with multiple
testsuites :-)
