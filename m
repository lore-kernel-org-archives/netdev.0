From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Re[2]: net_device + pci_dev question
Date: Mon, 28 Nov 2005 22:03:38 +0100
Message-ID: <1133211819.2824.82.camel@laptopd505.fenrus.org>
References: <2510370984.20051127205827@gmail.com>
	 <1133126713.2853.45.camel@laptopd505.fenrus.org>
	 <1653628458.20051128215644@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751307AbVK1VDn@vger.kernel.org>
To: Mateusz Berezecki <mateuszb@gmail.com>
In-Reply-To: <1653628458.20051128215644@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-11-28 at 21:56 +0100, Mateusz Berezecki wrote:
> Hello Arjan,
> 
> On 27th november 2005 (22:25:13) you wrote:
> 
> > On Sun, 2005-11-27 at 20:58 +0100, Mateusz Berezecki wrote:
> >> Hello List!
> >> 
> >> Having only net_device pointer is it possible to retrieve associated pci_dev
> >> pointer basing on this information only?
> 
> > what do you need it for?
> 
> for pci_alloc_consistent() which takes pci_dev as a first argument to
> allocate contiguous memory block for DMA transfers. I just realized

oh it's *your own* netdev...

that makes things a lot easier ;)

it's custom to have driver private data per net dev
(see netdev_priv() to get it, alloc_etherdev() takes the size of it as
argument). It's custom to make that private data a struct in which you
can store the pci device pointer yourself, as well as any other per card
data that you need to store
