From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 7 Sep 2004 15:02:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907150204.119ba849.davem@redhat.com>
References: <413E2C26.5040108@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Buckingham <peter@pantasys.com>
In-Reply-To: <413E2C26.5040108@pantasys.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Sep 2004 14:46:14 -0700
Peter Buckingham <peter@pantasys.com> wrote:

> I was playing around with using ipconfig to initialise a bunch of 
> systems and it turns out that the ipconfig code doesn't check to see 
> whether the ACK is for it or another system. I've just added a simple 
> check to compare the hardware address of the device to the one in the 
> packet.

Just because there are 16 bytes of hw address in the bootp packet
layout doesn't mean the device actually has that many.  Please fix
it to use dev->addr_len.
