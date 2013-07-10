From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [GIT] Networking
Date: Wed, 10 Jul 2013 12:52:04 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F61BD3D@DE02WEMBXB.internal.synopsys.com>
References: <20130709.145325.1363244885668360965.davem@davemloft.net>
	<20130710122523.GA357@x4>
 <CA+5PVA5AT0OLNi-=x91ks5AbigymE3BDmdoEiiNOeRoGFCFQfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	"Alexey Brodkin" <Alexey.Brodkin@synopsys.com>
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hermes.synopsys.com ([198.182.44.81]:48321 "EHLO
	hermes.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab3GJMxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 08:53:18 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2013 04:43 PM, Josh Boyer wrote:
> On Wed, Jul 10, 2013 at 8:25 AM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
>> +config NET_VENDOR_ARC
>> +       bool "ARC devices"
>> +       default y
>
> That's the option to enable the ARC vendor, not the driver.  The
> driver config option is ARC_EMAC.  All of the other ethernet vendors
> also default to y, so I don't think this is out of line.

Correct I noticed that all other vendors are enabled by default.

And as for arc_emac driver itself it's "tristate "ARC EMAC support"". So 
not selected by default.

-Alexey
