From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch driver
 (ESW)
Date: Fri, 26 Feb 2016 10:34:31 -0800
Message-ID: <56D09AB7.3000203@gmail.com>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
 <1456496504-50429-4-git-send-email-blogic@openwrt.org>
 <20160226151813.GD12022@lunn.ch> <56D06E3F.1020100@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Fred Chang (?????????)" <Fred.Chang@mediatek.com>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	netdev@vger.kernel.org,
	"Carlos Huang (?????????)" <Carlos.Huang@mediatek.com>,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: John Crispin <blogic@openwrt.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D06E3F.1020100@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/02/16 07:24, John Crispin wrote:
> 
> Hi,
> 
> would the series be ok if we just dropped those parts and then have a
> driver in the kernel that wont do much with the out of tree patches ?
> 
> the problem here is that on one side people complain about vendors not
> sending code upstream. once they start being a good citizen and provide
> funding to send stuff upstream the feedback tends to be very bad as seen
> here.

I agree with David here, the feedback from Andrew is very constructive,
you just don't like the feedback you are being given, which is a
different thing. You can't always get a 12 series patches adding a new
driver accepted after second try, look at all the recent submissions
that occured, it took 5-6-7 maybe more submissions until things were in
a shape where they could be merged. If for your next submission you get
the feedback that switchdev/DSA is deprecated, and something new needs
to be used, then I would agree that feedback is not acceptable, I doubt
this will be the case unless we wait another 10 years to get these
patches out.

> we are planning on doing a DSA driver but one step at a time. this
> kind of feedback will inevitably lead to vendors doing second thoughts
> of upstream contributions.

If you are planning on a DSA driver, which sounds like a good plan, then
maybe drop the integrated switch parts for now, keep it as a local set
of patches for your testing, and just get the basic CPU Ethernet MAC
driver to work for data movement, so that part gets in, and later on,
when your DSA driver is ready, that's one less thing to take care of.
They ultimately are logically spearated drivers if you use DSA, a little
less if you use switchdev.
-- 
Florian
