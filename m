From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dlci - cleanup for 2.6
Date: Wed, 3 Sep 2003 20:33:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903203336.45e0bce6.davem@redhat.com>
References: <20030903151847.7311f75f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mike.mclagan@linux.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030903151847.7311f75f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 15:18:47 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Patch for 2.6.0-test4 to cleanup DLCI driver
> - keep list of arrays for devices and use a lock
> - make sure header is contiguous before overlaying data structure
> - dynamically allocate dev->priv with alloc_netdev
> - get rid of MOD_INC/DEC
> - free devices on module unload
> - keep refcount on slave device's since holding a ptr

Applied.

I assume you added the module export of unregister_frad() because you
intend to make some drivers actually make use of it? :-)
