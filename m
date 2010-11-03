From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Wed, 03 Nov 2010 08:28:22 -0700 (PDT)
Message-ID: <20101103.082822.193702985.davem@davemloft.net>
References: <1288075928.6578.185.camel@concordia>
	<20101030232155.GA14129@parisc-linux.org>
	<1288788357.989.77.camel@concordia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, bhutchings@solarflare.com,
	somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: michael@ellerman.id.au
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1288788357.989.77.camel@concordia>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <michael@ellerman.id.au>
Date: Wed, 03 Nov 2010 23:45:57 +1100

> On Sat, 2010-10-30 at 17:21 -0600, Matthew Wilcox wrote:
>> On Tue, Oct 26, 2010 at 05:52:08PM +1100, Michael Ellerman wrote:
>> > That horse has really really bolted, it's gawn.
>> > 
>> > I count 26 drivers with "disable MSI/X" parameters. Some even have more
>> > than one.
>> 
>> That's 26 patches someone needs to write, then.  You can put my Acked-by
>> on all of them.
> 
> Bah, come on it's hardly the most horrendous sin committed by driver
> writers.

Yes but it's pretty high on the list because it deteriorates the
user experience.

It's a real selfish move to try and "fix" things in this way and
we've established that this isn't acceptable in the past.
