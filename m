From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 13:27:52 -0500
Message-ID: <4E42CDA8.5050902@freescale.com>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>	<1312945564-6626-6-git-send-email-holt@sgi.com>	<4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com>	<9C64B7751C3BCA41B64A68E23005A7BE1C6A21@039-SN1MPN1-002.039d.mgd.msft.net> <20110810160054.GT4926@sgi.com> <4E42CCB0.8090803@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robin Holt <holt@sgi.com>, U Bhaskar-B22300 <B22300@freescale.com>,
	Wood Scott-B07421 <B07421@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:33097
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751807Ab1HJS16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 14:27:58 -0400
In-Reply-To: <4E42CCB0.8090803@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2011 01:23 PM, Wolfgang Grandegger wrote:
> On 08/10/2011 06:00 PM, Robin Holt wrote:
>> On Wed, Aug 10, 2011 at 02:36:20PM +0000, U Bhaskar-B22300 wrote:
> ...
>> It looks like the way to do that is to assign a label to those devices
>> and then associate the label with an alias.  I have no idea how that
>> works under the hood, but it is the way other files are set up.  Take a
>> look at arch/powerpc/boot/dts/bamboo.dts for how they define the serial
>> interfaces.
> 
> With a label you mean "label:" at the beginning of a node. Such labels
> are translated by the device tree compiler in node handles, which can be
> referenced within nodes by using <&label>, e.g.:
> 
> UIC0: interrupt-controller0 {
> 	...
> };
> UIC1: interrupt-controller1 {
> 	...
> 	interrupt-parent = <&UIC0>;
> 	...
> };
> 
> It has nothing to do with the name of the node.

"...and then associate the label with an alias."

The alias can then be used if you want "can0" versus "can1".

Appending numbers to the node name is typically only done when there's
no unit address, and a need to disambiguate.

-Scott

