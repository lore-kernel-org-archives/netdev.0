From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sun, 26 Feb 2006 00:58:02 +0000
Message-ID: <1140915482.23286.6.camel@localhost.localdomain>
References: <43FF88E6.6020603@linux.intel.com>
	 <20060225084139.GB22109@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	okir@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750885AbWBZAyg@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060225084139.GB22109@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sad, 2006-02-25 at 08:41 +0000, Christoph Hellwig wrote:
> the regualatory problems are not true.  

They are although the binary interpretation isn't AFAIK from law but
from lawyers. The same is actually true in much of the EU. The actual
requirement is that the transmitting device must be reasonably
tamperproof. Some of the lawyers have decided that for a software radio
tamperproof means "binary".

Thats pretty dumb but given the hardware variant of this is "seal
anything adjustible in plastic gunge" you can see the logic at work -
and it *will* help make the product tamperproof to end users. Remember
Christoph you are not an "end user" any more than hardware like that is
designed to proof against a person who can use a scope and solder
surface mount components.

Now a smart vendor would have put MD5 sum checking into the chip so you
can only load register sets for the transmitter as a block and that
block is loaded such that

	[Data] + Secret known only to chip = MD5sum with data

or a similar cookie signing scheme. Replay attacks don't matter here so
that should be sufficient.
