From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 4 Dec 2004 01:59:46 +0100
Message-ID: <20041204005946.GA26654@electric-eye.fr.zoreil.com>
References: <200412032325.iB3NPdG04693@xos037.xos.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jos Vos <jos@xos.nl>
Content-Disposition: inline
In-Reply-To: <200412032325.iB3NPdG04693@xos037.xos.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jos Vos <jos@xos.nl> :
[misbehaving multi port e1000]
> Any suggestions how to solve this are welcome.  I can provide more
> information if needed.

<I am not the e1000 maintainer>

The error code for the ioctl most probably comes through
e1000_open
-> e1000_up
   -> request_irq

That + (2) + SMP suggests an irq routing issue due to a broken acpi
table ("suggests").

I would compile a (monolithic) recent 2.6.x to see its log and
give a look at http://acpi.sourceforge.net/dsdt/index.php (once the
ticket is opened at http://bugzilla.redhat.com of course :o) )

--
Ueimor
