From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Thu, 10 Jul 2014 22:20:30 +0100
Message-ID: <20140710222030.0a194b1b@alan.etchedpixels.co.uk>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
	<1404723967-24245-2-git-send-email-olivier@sobrie.be>
	<20140708.161633.2130069042930765600.davem@davemloft.net>
	<20140710142848.GA28056@hposo>
	<063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
	<20140710165003.0309924e@alan.etchedpixels.co.uk>
	<063D6719AE5E284EB5DD2968C1650D6D17270187@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Olivier Sobrie'" <olivier@sobrie.be>,
	David Miller <davem@davemloft.net>,
	"j.dumon@option.com" <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17270187@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You really want to apply flow control back over the 'serial' link.
> That may just cause data discards earlier on the local system.
> But it is possible that not resubmitting the receive urb will cause the
> modem to flow control back to the sender.
> In which case there is some chance that data won't be lost.

If you are doing PPP and you can't keep up the sooner you chuck data the
better. Flow control actually works against performance and good network
behaviour. It's counter intuitive but TCP/IP works best if any
performance bottlenecks are immediately visible and not covered over.

Alan
