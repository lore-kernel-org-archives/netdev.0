From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 PKT_SCHED] Report qdisc parent to userspace
Date: Fri, 24 Sep 2004 14:52:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924125240.GT31616@rei.reeler.org>
References: <20040924123710.GB3944@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924123710.GB3944@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20040924123710.GB3944@postel.suug.ch> 2004-09-24 14:37
> Report parent classid of a qdisc back to userspace. Without this there
> is no way for userspace to see if the qdisc is attached to a class
> other than parsing all class trees of the link and check all tcm_info
> fields in the leaf classes.

Don't include this patch yet. I think i missed a case when
tcm_parent is set to a non-existant classid but gets attached to the
root class.
