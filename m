From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] vlan - device refcount bug.
Date: Mon, 9 Aug 2004 16:49:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809164901.105a9e95.davem@redhat.com>
References: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 13:14:25 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> If you rmmod a network device that is in a vlan, the system hangs waiting
> for the refcount to go to zero, because it is -1.  The problem is that the
> vlan notifier does an extra dev_put in NETDEV_UNREGISTER case of notifier.

Applied.
