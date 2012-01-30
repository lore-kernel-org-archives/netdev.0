From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [00/22] Cyclades PC300 driver: summary of patch series
Date: Mon, 30 Jan 2012 10:28:15 +0000
Message-ID: <20120130102815.3e01acc4@pyramind.ukuu.org.uk>
References: <20120130024243.GA10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130024243.GA10262@cronus.persephoneslair.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Jan 2012 18:42:43 -0800
Andrea Shepard <andrea@persephoneslair.org> wrote:

> The Cyclades PC-300 is a line of PCI synchronous serial cards, which was
> produced in single and dual port models with either T1/E1 or V.35 ports.
> It used a Hitachi HD64572 (SCA-II) synchronous serial chip, and in the
> T1/E1 models an Infineon FALC-LH line interface/framing chip.  Copies
> of the hardware documentation may be found at [1].

The cleanup is better than it was but has lots left to sort. I think this
may actually be a good example of where the staging tree is useful as
it'll avoid this turning into a hundred cycles of adding another patch to
the enormous pile and can instead be done in step by step.

Alan
