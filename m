From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (4/4) Support for lots of netdev's -- faster
 dev_alloc_name
Date: Fri, 6 Feb 2004 14:37:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206143757.53cd8adb.davem@redhat.com>
References: <20040206101232.46bc30b1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040206101232.46bc30b1.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 10:12:32 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert dev_alloc_name from O(n^2) lookup to O(n) by using a page as
> bitmap to figure out how many devices of that pattern have been allocated.
> This works for up to 32k devices (PAGE_SIZE*8) on i386, more on other
> platforms.  Correctly handles the boundary cases where number of devices
> won't fit because name length is limited.
> 
> Adds strnchr to the string libraries since we need to find the % format
> character, but only care if it is in the first 15 bytes.

Ok, applied, thanks Stephen.
