From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bugtrap for network drivers that don't register
 properly.
Date: Thu, 16 Oct 2003 16:32:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016163259.231a6817.davem@redhat.com>
References: <20031016110417.0774e1c7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031016110417.0774e1c7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003 11:04:17 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch adds checks for network devices that set there statistics pointer
> after registration.  It is a common error and has already burned netdev sysfs
> unregister a couple of times.  Rather than trapping it on module unload which
> is infrequent and unlikely to be tested on all devices, this patch traps it
> when the device is brought up.
> 
> Tested on 2.6.0-test7 by buggering the e100 driver.

Applied, thanks Stephen.
