From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Wed, 23 Mar 2005 10:16:23 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3E32@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:

> 
> On Tue, 22 Mar 2005 18:50:36 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Sorry, I still disagree.  We need to think about how to handle this
> > situation for -all- drivers and -all- users, not just tg3.
> 
> When you come up with something that doesn't require the 
> users to ask around and report stuff when MSI doesn't work, 
> let me know.
> 
> But for now let's hold off on the tg3 MSI support, ok?
> 
> 

Jeff, I understand your point of view which is from the kernel development
perspective. For us, we have to consider the user's perspective when he is
trying to figure out why things are not working. Let's see if we can address
your concerns with the following:

#1. Keep the msi test but add a message telling the user to report to the PCI
maintainer when msi test fails, as David suggested.

#2. Do the msi test and if it fails, just print a message telling the user to
disable MSI some other way and report to PCI maintainer. This will at least
identify the potential problem to the user.

Michael
