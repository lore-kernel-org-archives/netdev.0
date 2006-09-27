From: castet.matthieu@free.fr
Subject: Re: softmac mtu
Date: Wed, 27 Sep 2006 15:57:14 +0200
Message-ID: <1159365434.451a833ae7728@imp3-g19.free.fr>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org> <20060925200125.GF16949@tuxdriver.com> <20060927143905.721ddf3e@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:43746 "EHLO smtp1-g19.free.fr")
	by vger.kernel.org with ESMTP id S932075AbWI0Ngg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 09:36:36 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060927143905.721ddf3e@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Selon Jiri Benc <jbenc@suse.cz>:

> On Mon, 25 Sep 2006 16:01:32 -0400, John W. Linville wrote:
> > On Mon, Sep 25, 2006 at 07:17:31PM +0000, Matthieu CASTET wrote:
> > > So why a special mtu handler is not implemented in 802.11 stack :
> > > - 802.11 stack doesn't support bigger packet
> > > - 802.11 stack doesn't support very bigger packet (with
> > > 802.11 fragmentation)
> > > - 802.11 writers were lazy
> >
> > I suspect the latter...patches welcome! :-)
>
> d80211 supports larger MTU.
>
I have a patch for 802.11 linux stack.
It works for mtu like 2000 but if the packet is fragmented (with mtu = 3000 for
example) my usb dongle (zd1211) crash (doesn't work anymore until I replug it).
I need to investigate a bit.

Also I wonder what should be the max mtu.

Matthieu
