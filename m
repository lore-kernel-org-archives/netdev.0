From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH 2.6] eepro100: remove ID for 82556
Date: Sat, 19 Feb 2005 10:08:02 +0200
Message-ID: <E1D2Pek-0007RZ-Tk@rhn.tartu-labor>
References: <4216C8A3.4020303@pobox.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
In-Reply-To: <4216C8A3.4020303@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

JG> I see the thread, but I still worry about removing the id in your patch, 
JG> since the poster in the thread says that they had to -add- an ID to both 
JG> e100 and eepro100 in order to perform their test.
JG> 
JG> Has anyone with this PCI ID actually confirmed that eepro100 does not 
JG> work for them?

I added the PCI ID only to e100, it was already present in eepro100.

Neither unmodified eepro100 nor pci-id-added e100 worked with this
chip so IMHO it's safe to remove this PCI ID from eepro100 too.

-- 
Meelis Roos
