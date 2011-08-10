From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v11 5/5] powerpc: Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 12:36:22 -0500
Message-ID: <4E42C196.7030708@freescale.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com> <1312993670-23999-6-git-send-email-holt@sgi.com> <4E42B83C.2040705@freescale.com> <20110810171933.GW4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	<socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	<devicetree-discuss@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:13184
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416Ab1HJRgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 13:36:31 -0400
In-Reply-To: <20110810171933.GW4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2011 12:19 PM, Robin Holt wrote:
> On Wed, Aug 10, 2011 at 11:56:28AM -0500, Scott Wood wrote:
>> On 08/10/2011 11:27 AM, Robin Holt wrote:
>>> -CPI Clock- Can Protocol Interface Clock
>>> -	This CLK_SRC bit of CTRL(control register) selects the clock source to
>>> -	the CAN Protocol Interface(CPI) to be either the peripheral clock
>>> -	(driven by the PLL) or the crystal oscillator clock. The selected clock
>>> -	is the one fed to the prescaler to generate the Serial Clock (Sclock).
>>> -	The PRESDIV field of CTRL(control register) controls a prescaler that
>>> -	generates the Serial Clock (Sclock), whose period defines the
>>> -	time quantum used to compose the CAN waveform.
>>> +- compatible : Should be "fsl,flexcan" and optionally
>>> +               "fsl,flexcan-<processor>"
>>
>> fsl,<processor>-flexcan, and it should not be optional, and should come
>> before "fsl,flexcan".
>>
>> Also may want to list fsl,p1010-rdb as a "canonical compatible" for
>> anything which is backwards compatible with p1010's implementation.
> 
> How do I specify 'canonical compatible'?

Something like:

  compatible: Should be "fsl,<processor>-flexcan" and "fsl,flexcan".

  An implementation should also claim any of the following compatibles
  that it is fully backwards compatible with:

  - fsl,p1010-rdb

> What would be the use of it in that implementation?

It limits the number of compatibles a driver has to care about, so you
don't need a huge ID table just to be able to figure out whether this is
a p1010-style flexcan or ARM-style.

-Scott

