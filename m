From: jamal <hadi@cyberus.ca>
Subject: Re: Interconnect virtual device?
Date: 28 Feb 2005 07:06:06 -0500
Message-ID: <1109592365.2188.914.camel@jzny.localdomain>
References: <4222A8F2.6080004@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4222A8F2.6080004@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-28 at 00:15, Ben Greear wrote:
> Hello!
> 
> I am considering writing a kernel module to provide a very
> simple virtual interface.  This interface would be attached
> to another interface, and would not be directly associated with
> hardware.  It can have IP addresses & routing tables, and in
> almost every way appear to be a regular ethernet interface.
> 
> The idea is that when you tx on this virtual interface, it
> will cause a packet to be received on another interface.  And,
> when a packet is received on the interface, it will tx on the
> other interface.
> 

In other words, it redirects to another device - I take it based on some
rules. Sounds to me like the mirred action already does this (and in
addition can mirror).

> I believe I can use this to create some interesting effects with
> routing and bridging on a limitted number of physical interfaces.
> 

What "interesting effects" ?

cheers,
jamal
