From: Jos Vos <jos@xos.nl>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 4 Dec 2004 02:14:44 +0100
Message-ID: <20041204021444.A5058@xos037.xos.nl>
References: <200412032325.iB3NPdG04693@xos037.xos.nl> <20041204005946.GA26654@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041204005946.GA26654@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Dec 04, 2004 at 01:59:46AM +0100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 04, 2004 at 01:59:46AM +0100, Francois Romieu wrote:

> That + (2) + SMP suggests an irq routing issue due to a broken acpi
> table ("suggests").

IIRC ACPI is disabled in the BIOS (not sure), but I'm using a
RHEL3 2.4.21 kernel that does not support ACPI at all (due to
the RH patches rebuilding the kernel with ACPI enbabled does
not work anymore)!

> I would compile a (monolithic) recent 2.6.x to see its log and
> give a look at http://acpi.sourceforge.net/dsdt/index.php (once the
> ticket is opened at http://bugzilla.redhat.com of course :o) )

Well, I could do that, but the idea was to use this in a RHEL3
system, so ...

-- 
--    Jos Vos <jos@xos.nl>
--    X/OS Experts in Open Systems BV   |   Phone: +31 20 6938364
--    Amsterdam, The Netherlands        |     Fax: +31 20 6948204
