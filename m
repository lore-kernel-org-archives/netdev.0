From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Mon, 29 Sep 2003 22:49:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929224929.4dc6ed4a.davem@redhat.com>
References: <20030929143642.18b491ba.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cramerj@intel.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20030929143642.18b491ba.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 14:36:42 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Oh, it's taking xmit_lock in a timer handler.  I give up.

I think e1000 should rethink what it is doing :-)
