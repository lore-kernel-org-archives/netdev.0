From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Mon, 15 Mar 2004 23:00:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315220011.GC20830@wotan.suse.de>
References: <20040315134412.314b5e23.davem@redhat.com> <Pine.LNX.4.44.0403152350260.6903-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, timg@tpi.com, anton@samba.org,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0403152350260.6903-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Isn't there a problem when an outside attacker brute-force pings every 
> IP address in some order?  The intent here is to overload the router 
> to do a lot of ARP/ND requests which result to nothing.

Note that the max number of active neighbours per interface is limited. There
is a natural limit on how many entries the hash tables can have.
The user can increase this with sysctls, but the defaults should be 
safe.

-Andi
