From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 20:24:18 -0600
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFE94343B@MNEXMB2.qlogic.org>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>,<20100105090717.15d532ce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12263 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab0AFC2U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 21:28:20 -0500
In-Reply-To: <20100105090717.15d532ce@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I bisected patches logically, for ease of understanding.
If single patch is requirement, I can do that also.
________________________________________
From: Stephen Hemminger [shemminger@vyatta.com]
Sent: Tuesday, January 05, 2010 10:37 PM
To: Amit Salecha
Cc: davem@davemloft.net; netdev@vger.kernel.org; Dhananjay Phadke
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for CNA devices

On Tue,  5 Jan 2010 05:24:34 -0800
Amit Kumar Salecha <amit.salecha@qlogic.com> wrote:

> Hi
>   Series of 2 patches to add Qlogic ethernet driver for QLE8240 and
>   QLE8242 CNA devices. QLE8240 and QLE8242 devices support various
>   class of drivers.
>   Please apply to net-next tree.
>
> -Amit Salecha
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The patches are out of order. If patch 1 was applied (but not patch 2),
then it would be possible to configure device but the actual driver
code would not be there. This could happen when doing git bisect.

I assume Dave will just resolve this by combining the two before
merging.

--
