From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (8/8) loopback device simplification
Date: Thu, 4 Sep 2003 12:07:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904120743.3b96e738.davem@redhat.com>
References: <20030903164921.7d923008.shemminger@osdl.org>
	<3F568AC0.5090601@pobox.com>
	<20030903204105.0f01f131.davem@redhat.com>
	<20030904121421.51b2f993.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030904121421.51b2f993.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003 12:14:21 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Wed, 3 Sep 2003 20:41:05 -0700
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > The fact that we export the list and it's locking makes it
> > really hard to change things.
> 
> my current idea is to switch dev_base_lock over to RCU and
> change dev_base to a list macro.
> 
> #define for_each_netdev(_d)   list_for_each_entry_rcu(_d, &netdev_base, dev_list)

Also see other threads where we were discussing making
it into a hash table in order to speed up search and
name allocation.
