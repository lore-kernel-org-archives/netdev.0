From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add /proc/net/tcp_listen
Date: Thu, 17 Jun 2004 20:39:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617203909.1e7f7f9c.davem@redhat.com>
References: <20040618043151.0483c158.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040618043151.0483c158.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Use netlink tcp_diag.  It's built specifically for this.
Just pass in the suitable fuilter, state == TCP_LISTEN.

inetd and tcpd had support added, so adding support for this
openslp thing should be similarly trivial.
