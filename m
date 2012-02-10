From: Julia Lawall <julia.lawall@lip6.fr>
Subject: RE: [PATCH net-next] drivers/net: Remove boolean comparisons to
 true/false
Date: Fri, 10 Feb 2012 07:46:01 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1202100745050.1981@hadrien>
References: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>  <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>  <20120209.133413.349832435589531136.davem@davemloft.net>  <1328822243.29329.11.camel@joe2Laptop>
 <1328822935.2242.1.camel@jtkirshe-mobl>  <804857E1F29AAC47BF68C404FC60A1842709C1@ORSMSX102.amr.corp.intel.com> <1328828918.29329.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:6950 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452Ab2BJGqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 01:46:04 -0500
In-Reply-To: <1328828918.29329.21.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Feb 2012, Joe Perches wrote:

> On Thu, 2012-02-09 at 22:36 +0000, Allan, Bruce W wrote:
>>> On Thu, 2012-02-09 at 13:17 -0800, Joe Perches wrote:
>>>> Booleans should not be compared to true or false
>>>> but be directly tested or tested with !.
>>>>
>>>> Done via cocci script:
>>>>
>>>> @@
>>>> bool t;
>>>> @@
>>>> - t == true
>>>> + t
>>>> @@
>>>> bool t;
>>>> @@
>>>> - t != true
>>>> + !t
>>>> @@
>>>> bool t;
>>>> @@
>>>> - t == false
>>>> + !t
>>>> @@
>>>> bool t;
>>>> @@
>>>> - t != false
>>>> + t
>
>> Has the cocci script been (or will it be) added to ./scripts/coccinelle?
>
> These are pretty trivial scripts.
>
> You're welcome to add it or combine it
> with the one Rusty did to convert
> bool foo = 1
> to
> bool foo = true
>
> https://lkml.org/lkml/2011/12/19/15

It would indeed seem nice to put them all together.  I can do that.

julia
