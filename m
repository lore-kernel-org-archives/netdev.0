From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] multiple eth0 mixed PCI/ISA init
Date: Mon, 5 Jan 2004 12:56:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105125659.56c2f6b5.davem@redhat.com>
References: <20040105111059.4a451146.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040105111059.4a451146.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 5 Jan 2004 11:10:59 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch for 2.6 fixes the problem found by Zoltan Farkas 
> with mixed PCI/ISA and a non-modular config.  The problem is the old_netdev
> ISA probing isn't skipping "eth0" which already got assigned by the PCI
> initialization.

Applied, thanks Stephen.
