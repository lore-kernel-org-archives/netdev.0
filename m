From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 9 Aug 2011 13:17:47 -0500
Message-ID: <4E4179CB.6030101@freescale.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com> <1312901031-29887-6-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	<netdev@vger.kernel.org>, <socketcan-core@lists.berlios.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:48013
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751061Ab1HISSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 14:18:07 -0400
In-Reply-To: <1312901031-29887-6-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2011 09:43 AM, Robin Holt wrote:
> In working with the socketcan developers, we have come to the conclusion
> the fsl-flexcan device tree bindings need to be cleaned up. 
> The driver does not depend upon any properties other than the required properties
> so we are removing the file.

That is not the criterion for whether something should be expresed in
the device tree.  It's a description of the hardware, not a Linux driver
configuration file.  If there are integration parameters that can not be
inferred from "this is FSL flexcan v1.0", they should be expressed in
the node.

Removing the binding altogether seems extreme as well -- we should have
bindings for all devices, even if there are no special properties.

> Additionally, the p1010*dts files are not
> following the standard for node naming in that they have a trailing -v1.0.

What "standard for node naming"?  There's nothing wrong with putting a
block version number in the compatible string, and it looks like the
p1010 dts files were following the binding document in this regard.  It
is common practice when the block version is publicly documented but
there's no register it can be read from at runtime.

-Scott

