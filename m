From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more sdla fixes
Date: Fri, 5 Sep 2003 02:46:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905024622.19c87878.davem@redhat.com>
References: <20030904144248.0599cdaf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030904144248.0599cdaf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003 14:42:48 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Since sdla.c now has locking instead of cli/sti, it shouldn't be
> completely busted on SMP.
> 
> Also, the frad interface registration needed to be done once
> (and check the result), and undone on module unload.

Looks good, applied.
