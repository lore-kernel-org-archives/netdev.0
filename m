From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [OOPS] bcm43xx oops on 2.6.20-rc1 on x86_64
Date: Sat, 30 Dec 2006 23:14:58 -0600
Message-ID: <45974752.90601@lwfinger.net>
References: <Pine.LNX.4.64.0612171510030.17532@squeaker.ratbox.org> <20061230192104.GB20714@stusta.de> <Pine.LNX.4.64.0612302312520.27190@squeaker.ratbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org,
	st3@riseup.net, linville@tuxdriver.com, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932789AbWLaFOo@vger.kernel.org>
To: Aaron Sethman <androsyn@ratbox.org>
In-Reply-To: <Pine.LNX.4.64.0612302312520.27190@squeaker.ratbox.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron Sethman wrote:
> 
> On Sat, 30 Dec 2006, Adrian Bunk wrote:
> 
>> On Sun, Dec 17, 2006 at 03:15:28PM -0500, Aaron Sethman wrote:
>>>
>>> Just was loading the bcm43xx module and got the following oops. Note
>>> that
>>> this card is one of the newer PCI-E cards.  If any other info is needed
>>> let me know.
>>
>> Is this issue still present in 2.6.10-rc2-git1?
>>
>> If yes, was 2.6.19 working fine?
>>
> 
> This seems to be fixed in 2.6.20-rc2-git1.  Still having other issues
> with the driver, but the oops in the SoftMAC code is resolved now at least.

I have just started working with the PCI-E BCM4311 that is in my new computer. It receives data OK,
but there is something wrong with the DMA out stuff in bcm43xx-softmac - at least for x86_64. All
the slots get full but nothing is ever transmitted. FWIW, the wireless-dev git tree works. I'm using
it for communications now. I'm using openSUSE 10.2 which uses NetworkManager to configure my WPA-PSK
TKIP encrypted network. The signal strengths are roughly the same as I got for my old BCM4306 card.

I will post any fixes for the DMA problem as soon as they are available, but it may be a while. I
will be off-line until Thursday while I attend a funeral.

Larry
