From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Mark SIOCSIFNAME as compatible ioctl
Date: Fri, 9 Jan 2004 02:04:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109020456.045b447e.davem@redhat.com>
References: <20040108070413.GA31778@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040108070413.GA31778@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jan 2004 08:04:13 +0100
Andi Kleen <ak@muc.de> wrote:

> Mark SIOCSIFNAME as an ioctl that doesn't need 32bit conversion.
> 
> Fixes nameif as 32bit executable.

How can we mark it compatible?  It needs the stuff dev_ifname32() in
fs/compat_ioctl.c does for SIOCGIFNAME doesn't it?
