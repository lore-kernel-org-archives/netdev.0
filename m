From: Jos Vos <jos@xos.nl>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Mon, 6 Dec 2004 12:51:51 +0100
Message-ID: <20041206125151.A24753@xos037.xos.nl>
References: <200412032325.iB3NPdG04693@xos037.xos.nl> <1102204801.3343.68.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1102204801.3343.68.camel@sfeldma-mobl.dsl-verizon.net>; from sfeldma@pobox.com on Sat, Dec 04, 2004 at 04:00:01PM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 04, 2004 at 04:00:01PM -0800, Scott Feldman wrote:

> The 4-port card has two 82546 dual-port controllers behind a PCI-X
> bridge.  Your symptoms suggest interrupt routing didn't get setup
> correctly for the controllers behind the bridge.  I've seen more than
> one case where the BIOS gets this wrong.  The fix is to upgrade to the
> latest BIOS.  Hopefully this is the fix for you.  :-)

I just a prerelease of their next BIOS from Supermicro and that seems
to solve the problem!

I still have to boot the SMP kernel to get APIC working, in UP mode
incoming packets are not seen, but I can live with that.

-- 
--    Jos Vos <jos@xos.nl>
--    X/OS Experts in Open Systems BV   |   Phone: +31 20 6938364
--    Amsterdam, The Netherlands        |     Fax: +31 20 6948204
