From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [NETLINK] fix broken indentation in netlink.h
Date: Thu, 10 Feb 2005 17:32:01 -0800
Message-ID: <20050210173201.21da89e5.davem@davemloft.net>
References: <420BF8C3.3050305@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <420BF8C3.3050305@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 01:13:55 +0100
Pablo Neira <pablo@eurodev.net> wrote:

> the subject says all

Don't split up lines like from:

extern int func(...);

into:

extern int
func(...);

That's just gross and means that when I run grep on the tree I
won't see the function's return type for hits, I'll only see the
args.

Just keep the long declarations.

Why don't you bypass all the cleanup diffs and just do the functionality
change instead?  When you mix whitespace and coding style cleanups
with real changes, it puts your real changes at risk if we think your
cleanups are ugly or bogus since you've created a patch dependency.

One thing at a time.
