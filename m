From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ] more RTL-8139 clone boards
Date: Wed, 19 Nov 2003 12:37:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBBAA5E.5020007@pobox.com>
References: <3FBA771A.1010104@wanadoo.es> <20031119092751.3407c944.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xose Vazquez Perez <xose@wanadoo.es>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031119092751.3407c944.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 18 Nov 2003 20:46:34 +0100
> Xose Vazquez Perez <xose@wanadoo.es> wrote:
> 
> 
>>0x018A 0x0106 LevelOne FPC-0106TX
>>0x126C 0x1211 Nortel Networks 10/100BaseTX
>>0x1743 0x8139 Peppercon AG ROL-F
>>0x021B 0x8139 Compaq HNE-300
> 
> 
> Maybe time to  start using pci_ids.h?


This is mainly a matter of opinion.  My opinion:  no.  ;-)

I think it's rather silly to keep adding to pci_ids.h, when the ids are 
just arbitrary hex numbers with no useful value.  I certainly support 
mnemonic constants when they have value... but if the _only_ place a PCI 
id constant exists is (a) in a pci_device_id list and (b) in pci_ids.h, 
then it seems rather wasteful rather than helpful.

IMO, the constants just bloat the pci_device_id list, whereas the ones 
with hex numbers are nice, single lines.

As an aside, include/linux/pci_ids.h is a heavily patched file, and 
conflicts occur all the time.

	Jeff
