From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/4) Support lots of netdev's -- hash ifindex
Date: Fri, 6 Feb 2004 13:44:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206134425.50577b1d.davem@redhat.com>
References: <20040206100501.6ffcfa8a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040206100501.6ffcfa8a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 10:05:01 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Hash network device index entries, to allow fast lookup by routing
> protocols.

Ok, I am applying this and the hash netdev by name patch.

I was going to allocate the tables at run time, not put them
into the image but since these go into the BSS it's not such
a big deal after all.

Thanks Stephen.
