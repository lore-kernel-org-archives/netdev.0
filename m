From: Dan Hollis <goemon@anime.net>
Subject: Re: [Bonding-devel] Re: [RFC][bonding] Improve VLAN support on top
 of bonding
Date: Tue, 15 Jul 2003 12:20:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307151213110.6196-100000@sasami.anime.net>
References: <Pine.LNX.4.51.0307151434100.4590@ns.istop.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0307151434100.4590@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003, Ralph Doncaster wrote:
> On Tue, 15 Jul 2003, Dan Hollis wrote:
> > That is exactly what it does. hw tcp checksumming helps a LOT at gbe rates
> This still doesn't make any sense.  The copy from user-space to kernel
> space does the checksum as far as I recall (unless you use the
> router-not-host kernel build option).

except that 2.5.x has zerocopy and I believe NFS supports it now as well

fwiw I believe sendfile() implementation was motivated a lot by hw csum 
support...

-Dan
-- 
[-] Omae no subete no kichi wa ore no mono da. [-]
