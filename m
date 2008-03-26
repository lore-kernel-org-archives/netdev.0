From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [NET] phy/broadcom: add support for BCM5481 PHY
Date: Wed, 26 Mar 2008 00:36:41 -0400
Message-ID: <47E9D2D9.3030900@pobox.com>
References: <20080203185804.GA30342@localhost.localdomain> <47A99DA0.3040505@pobox.com> <20080304164132.GA16552@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34269 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756311AbYCZEg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:36:56 -0400
In-Reply-To: <20080304164132.GA16552@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> On Wed, Feb 06, 2008 at 06:44:32AM -0500, Jeff Garzik wrote:
>> Anton Vorontsov wrote:
>>> This patch adds support for BCM5481 PHY. Unfortunately it's hard to
>>> get specifications for this PHY, so its special register 0x18 isn't
>>> annotated properly (but we know it's used to set up the delays).
>>>
>>> I've kept the magic numbers, so we'll not forget to fix it at the
>>> first opportunity, and will name that register and its bits correctly.
>>>
>>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> [...]
>>> +static struct phy_driver bcm5481_driver = {
>>> +	.phy_id		= 0x0143bca0,
>>> +	.phy_id_mask	= 0xfffffff0,
> [...]
>> applied
> 
> :-) You applied "PHYLIB: Add BCM5482 PHY support", but my
> patch is for another PHY -- BCM5481. Here is another try,
> rebased on top of previous commit:
> 
> - - - -
> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Subject: phylib, broadcom: add support for BCM5481 PHY
> 
> This patch adds support for BCM5481 PHY. Unfortunately it's hard to
> get specifications for this PHY, so its special register 0x18 isn't
> annotated properly (but we know it's used to set up the delays).
> 
> I've kept the magic numbers, so we'll not forget to fix it at the
> first opportunity, and will name that register and its bits correctly.
> 
> p.s. also fixed the line with broken indention, introduced by
> commit 03157ac31eb4a8883382a212b161d2e6c5059fbf
>     PHYLIB: Add BCM5482 PHY support
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  drivers/net/phy/broadcom.c |   57 +++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 56 insertions(+), 1 deletions(-)

applied


