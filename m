From: Allen Parker <parker@isohunt.com>
Subject: Re: intel 82571EB gigabit fails to see link on 2.6.20-rc5 in-tree
 e1000 driver (regression)
Date: Tue, 16 Jan 2007 09:17:26 -0700
Message-ID: <45ACFA96.4040902@isohunt.com>
References: <45AC7CB2.1010202@isohunt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751265AbXAPQT1@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <45AC7CB2.1010202@isohunt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allen Parker wrote:
> I have a PCI-E pro/1000 MT Quad Port adapter, which works quite well 
> under 2.6.19.2 but fails to see link under 2.6.20-rc5. Earlier today I 
> reported this to e1000-devel@lists.sf.net, but thought I should get the 
> word out in case someone else is testing this kernel on this nic chipset.
> 
> Due to changes between 2.6.19.2 and 2.6.20, Intel driver 7.3.20 will not 
> compile for 2.6.20, nor will the 2.6.19.2 in-tree driver.
> 
<snip, worthless>
Affected chipset:
> lspci -nn output (quad port):
> 09:00.0 Ethernet controller [0200]: Intel Corporation 82571EB Gigabit 
> Ethernet Controller [8086:10a4] (rev 06)
> lspci -nn output (dual port):
> 07:00.0 Ethernet controller [0200]: Intel Corporation 82571EB Gigabit 
> Ethernet Controller [8086:105e] (rev 06)
<snip, readability>

>  From what I've been able to gather, other Intel Pro/1000 chipsets work 
> fine in 2.6.20-rc5. If the e1000 guys need any assistance testing, I'll 
> be more than happy to volunteer myself as a guinea pig for patches.

I wasn't aware that I was supposed to post this as a regression, so 
changed the subject, hoping that someone will pick this up and run with 
it. Primary issue being that link is not seen on this chipset under 
2.6.20-rc5 via in-tree e1000 driver, despite multiple cycles of ifconfig 
$eth up && ethtool $eth | grep link && ifconfig $eth down. Tested on 2 
machines with identical hardware.

Allen Parker
