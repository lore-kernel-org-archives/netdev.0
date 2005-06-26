From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5721(tg3)&MSI
Date: Sat, 25 Jun 2005 21:48:51 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972067F0843@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Krzysztof Oledzki" <olel@ans.pl>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Krzysztof Oledzki wrote:
> Which BCM chips support MSI? I have a mainbord with two 
> BCM5721, it seems 
> both support MSI (Message Signalled Interrupts entry in 
> Capabilities) but 
> with 2.6.12.1 tg3 driver does not enable it. Why?
> 
> 04:00.0 Ethernet controller: Broadcom Corporation NetXtreme 
> BCM5721 Gigabit Ethernet PCI Express (rev 11)

MSI is only enabled on 5721 C0 and newer chips that have fully
working MSI. You are using 5721 B1.
