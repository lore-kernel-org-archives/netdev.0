From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6]: Fix device leaks in mirred action
Date: 04 Nov 2004 08:53:59 -0500
Message-ID: <1099576439.1038.147.camel@jzny.localdomain>
References: <4189CC6A.9040007@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4189CC6A.9040007@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-04 at 01:30, Patrick McHardy wrote:
> When a mirred action is created it takes two references to the
> device (dev_get_by_index + dev_hold), but only drops one when
> it gets destroyed. 

Good catch.
The correct fix is to remove the dev_hold(p->dev) call.

> It also leaks a reference when a mirred action
> is replaced.

How? Is this patch supposed to fix that?

cheers,
jamal
