From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Sun, 17 Aug 2003 22:18:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817221804.27e2f07d.davem@redhat.com>
References: <20030816175851.58a2c179.davem@redhat.com>
	<Pine.LNX.4.44.0308171335050.1409-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, shemminger@osdl.org, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Diehl <lists@mdiehl.de>
In-Reply-To: <Pine.LNX.4.44.0308171335050.1409-100000@notebook.home.mdiehl.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Aug 2003 19:42:40 +0200 (CEST)
Martin Diehl <lists@mdiehl.de> wrote:

> try_module_get(netdev->owner)

netdev->owner does not exist any more and we don't use module
refcounts to manage unload of network devices, it simply
is not needed.
