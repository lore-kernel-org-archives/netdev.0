From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bpqether add rcu_read_lock
Date: Wed, 13 Aug 2003 03:56:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813035638.3486f244.davem@redhat.com>
References: <20030811162205.78b2029f.shemminger@osdl.org>
	<20030812153312.0e762cf3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jreuter@yaina.de, linux-hams@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030812153312.0e762cf3.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 15:33:12 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix one comment and add rcu_read_lock/rcu_read_unlock in the net_device_notifier.
> Preemption is almost certainly already disabled there, but be safe.

Patch applied, thanks Stephen.
