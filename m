From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] de-inline qdiscipline locking functions.
Date: Wed, 28 Jul 2004 18:55:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728185501.3807c0f0.davem@redhat.com>
References: <20040726113402.25ba72ee@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040726113402.25ba72ee@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Jul 2004 11:34:02 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This qdisc code has several inline functions for locking that is only
> used when adding/deleting queuing disciplines; so make them functions
> instead.  The new qdisc_lock_tree encapsulates the locking used throughout
> this code.
> 
> Also qdisc_run() is only called from net/core/dev.c so it should be
> defined there.

Looks good, thanks Stephen.
