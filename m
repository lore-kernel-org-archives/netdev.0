From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Sun, 23 Aug 2009 22:02:27 +0200
Message-ID: <m3ljlati24.fsf@intrepid.localdomain>
References: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com>
	<m3skfmk39q.fsf@intrepid.localdomain>
	<20090823191808.GA29972@linux-gec2.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Walt Holman <walt@holmansrus.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Aviv Greenberg <avivgnet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934044AbZHWUC3@vger.kernel.org>
In-Reply-To: <20090823191808.GA29972@linux-gec2.site> (Aviv Greenberg's message of "Sun\, 23 Aug 2009 22\:18\:08 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aviv Greenberg <avivgnet@gmail.com> writes:

> Why do you use PCI_DMA_BIDIRECTIONAL? From what i get, the device writes and the
> cpu reads - so the direction should be PCI_DMA_FROMDEVICE. Maybe just maybe the 
> bi-directionality bites you in the swiotlb case.

Yes, it's just been confirmed that FROMDEVICE at this point happens to
work.
-- 
Krzysztof Halasa
