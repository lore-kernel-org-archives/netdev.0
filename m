From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network
 device renaming, for ipv4
Date: Mon, 1 Sep 2003 11:31:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901113143.1ba34464.davem@redhat.com>
References: <20030901164624.GA26886@callisto.yi.org>
	<20030901094127.6a0f6878.davem@redhat.com>
	<20030901165559.GA27099@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Aloni <da-x@gmx.net>
In-Reply-To: <20030901165559.GA27099@callisto.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 19:55:59 +0300
Dan Aloni <da-x@gmx.net> wrote:

> The private copy of strdup() is something that I'd also wouldn't
> want, but I don't have much choice. Please read a recent 
> thread in lkml regarding strdup() consolidation.

Ugh, I'm afraid to look...  I guess the controversy is
over the allocation function, what GFP_* flags it should
use etc.?

For now just call the thing in your patch netdev_name_dup() or
something like that.  I can't handle having something named
"strdup()" in there :-)
