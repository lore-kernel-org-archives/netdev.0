From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through
 eth0 on a Li
Date: Thu, 13 May 2004 10:31:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040513103139.08ebc779@dell_ss3.pdx.osdl.net>
References: <BAY15-F5TPEFoxcC3U000054055@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, dlstevens@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J. M." <snortwiz@hotmail.com>
In-Reply-To: <BAY15-F5TPEFoxcC3U000054055@hotmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 May 2004 12:20:34 -0500
"J. M." <snortwiz@hotmail.com> wrote:

> That's exactly what's happening - a service bound to an interface is 
> receiving traffic via a different interface.  That could pose security risks 
> on a dual-homed machine (such as the device I pen-tested and discovered this 
> flaw upon).
> 
> -Jared

On Linux, IP addresses are not bound to interfaces.  You need
to use SO_BINDTODEVICE if that is what you want. 

The security model is correct, and well defined, just different than BSD
derived systems.  It does conform to the standards (RFC's).
