From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] LSM networking: tcp hooks for 2.5.59 (8/8)
Date: Sat, 1 Feb 2003 11:12:33 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302011054440.4480-100000@blackbird.intercode.com.au>
References: <20030130.161638.83467438.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>,
   <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030130.161638.83467438.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Jan 2003, David S. Miller wrote:

> If you think this is implementable, then I'll happily accept the
> net/socket.c stuff and even the af_unix hack, with the assumption
> being that the rest can be handled by netfilter or something similar.
> Oh yes, I'd also take the netlink capability thing too as long as it
> was inlined properly for the no-security case.

Explicitly labeled networking and the SELinux extended sockets API
probably can't be supported with just these hooks and Netfilter.

However, this subset of the networking hooks will still be very useful in
general, and we'll rework the patch accordingly.


- James
-- 
James Morris
<jmorris@intercode.com.au>
