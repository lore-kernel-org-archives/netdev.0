From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Update STRIP driver
Date: Tue, 19 Aug 2003 21:04:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819210413.2891f84d.davem@redhat.com>
References: <20030819162156.4a9f6697.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030819162156.4a9f6697.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 16:21:56 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Update the STRIP driver.
> 	- set owner field on tty ldisc
> 	- allocate network device objects with alloc_netdev
> 	- use list_head macros and put locking around list of devices
> 	- convert to seq_file for /proc
> 	- use change_mtu hook rather than guessing at mtu changes

Applied, thanks Stephen.
