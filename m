From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Thu, 12 Jun 2003 01:11:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.011127.55861847.davem@redhat.com>
References: <20030609115857.38bb31d6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030609115857.38bb31d6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen, I applied all of your alloc_netdev() changes.

Even the TUN one, except I added the necessary dev_alloc_name()
call right before register_netdevice().
