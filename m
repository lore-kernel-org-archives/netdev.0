From: Phil Oester <kernel@linuxace.com>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Thu, 27 Jan 2005 12:40:12 -0800
Message-ID: <20050127204012.GA14518@linuxace.com>
References: <20050123023248.263daca9.akpm@osdl.org> <20050123200315.A25351@flint.arm.linux.org.uk> <20050124114853.A16971@flint.arm.linux.org.uk> <20050125193207.B30094@flint.arm.linux.org.uk> <20050127082809.A20510@flint.arm.linux.org.uk> <20050127004732.5d8e3f62.akpm@osdl.org> <16888.58622.376497.380197@robur.slu.se> <20050127164918.C3036@flint.arm.linux.org.uk> <20050127183745.GA13365@linuxace.com> <20050127192504.D3036@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, Andrew Morton <akpm@osdl.org>,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050127192504.D3036@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 07:25:04PM +0000, Russell King wrote:
> Can you provide some details, eg kernel configuration, loaded modules
> and a brief overview of any netfilter modules you may be using.
> 
> Maybe we can work out what's common between our setups.

Vanilla 2.6.10, though I've been seeing these problems since 2.6.8 or
earlier.  Netfilter running on all boxes, some utilizing SNAT, others
not -- none using MASQ.  This is from a box running no NAT at all,
although has some other filter rules:

# wc -l /proc/net/rt_cache ; grep dst_cache /proc/slabinfo
     50 /proc/net/rt_cache
ip_dst_cache       84285  84285

Also with uptime of 26 days.  

These boxes are all running the quagga OSPF daemon, but those that
are lightly loaded are not exhibiting these problems.

Phil
