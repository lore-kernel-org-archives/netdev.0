From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: [PATCH 2.6] eepro100: remove ID for 82556
Date: Sat, 19 Feb 2005 10:18:25 -0800
Message-ID: <56a8daef05021910184ababbe5@mail.gmail.com>
References: <4216C8A3.4020303@pobox.com> <E1D2Pek-0007RZ-Tk@rhn.tartu-labor>
Reply-To: John Ronciak <john.ronciak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <E1D2Pek-0007RZ-Tk@rhn.tartu-labor>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 82556 is not support by the e100 driver.  It is a different
architecture than the one started with the 82557 thru the current
generation of PRO/100 controllers.


On Sat, 19 Feb 2005 10:08:02 +0200, Meelis Roos <mroos@linux.ee> wrote:
> JG> I see the thread, but I still worry about removing the id in your patch,
> JG> since the poster in the thread says that they had to -add- an ID to both
> JG> e100 and eepro100 in order to perform their test.
> JG>
> JG> Has anyone with this PCI ID actually confirmed that eepro100 does not
> JG> work for them?
> 
> I added the PCI ID only to e100, it was already present in eepro100.
> 
> Neither unmodified eepro100 nor pci-id-added e100 worked with this
> chip so IMHO it's safe to remove this PCI ID from eepro100 too.
> 
> --
> Meelis Roos
> 
> 


-- 
Cheers,
John
