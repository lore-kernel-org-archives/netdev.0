From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 13:39:53 -0500
Message-ID: <4E42D079.7070709@freescale.com>
References: <1312945564-6626-1-git-send-email-holt@sgi.com> <1312945564-6626-6-git-send-email-holt@sgi.com> <4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com> <9C64B7751C3BCA41B64A68E23005A7BE1C6A21@039-SN1MPN1-002.039d.mgd.msft.net> <20110810160054.GT4926@sgi.com> <4E42CCB0.8090803@grandegger.com> <4E42CDA8.5050902@freescale.com> <20110810183526.GZ4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	Wood Scott-B07421 <B07421@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:38927 "EHLO
	TX2EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1HJSj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 14:39:56 -0400
In-Reply-To: <20110810183526.GZ4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2011 01:35 PM, Robin Holt wrote:
> On Wed, Aug 10, 2011 at 01:27:52PM -0500, Scott Wood wrote:
>> "...and then associate the label with an alias."
>>
>> The alias can then be used if you want "can0" versus "can1".
> 
> Does the alias get used by either the kernel or something else or is it
> just extra detail with no purpose?

It could be used by udev to produce a symlink.  Currently, the major
non-human consumer of the aliases is U-Boot.

-Scott

