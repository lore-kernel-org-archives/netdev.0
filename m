From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: Re[2]: net_device + pci_dev question
Date: Mon, 28 Nov 2005 21:56:44 +0100
Message-ID: <1653628458.20051128215644@gmail.com>
References: <2510370984.20051127205827@gmail.com>
 <1133126713.2853.45.camel@laptopd505.fenrus.org>
Reply-To: Mateusz Berezecki <mateuszb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750954AbVK1U5H@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1133126713.2853.45.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Arjan,

On 27th november 2005 (22:25:13) you wrote:

> On Sun, 2005-11-27 at 20:58 +0100, Mateusz Berezecki wrote:
>> Hello List!
>> 
>> Having only net_device pointer is it possible to retrieve associated pci_dev
>> pointer basing on this information only?

> what do you need it for?

for pci_alloc_consistent() which takes pci_dev as a first argument to
allocate contiguous memory block for DMA transfers. I just realized
when I saw your answer that I might have moved the memory allocation to
some routine which is called earlier in time which has access to
pci_dev pointer directly, like net_device->init IIRC. But I'm not
really sure if that would be correct solution.

> (and.. what if the nic isn't a pci one?)

Uh... it's cardbus interface and still uses pci_* stuff without problems. (?)
Do I miss something?

kind regards
Mateusz Berezecki
