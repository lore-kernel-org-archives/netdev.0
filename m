From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 9 Aug 2011 15:11:25 -0500
Message-ID: <4E41946D.4030003@freescale.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>	<1312901031-29887-6-git-send-email-holt@sgi.com>	<4E4179CB.6030101@freescale.com> <4E418B39.6040408@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Devicetree-discuss@lists.ozlabs.org"
	<Devicetree-discuss@lists.ozlabs.org>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	<socketcan-core@lists.berlios.de>, Robin Holt <holt@sgi.com>,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:24672
	"EHLO VA3EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752442Ab1HIULc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 16:11:32 -0400
In-Reply-To: <4E418B39.6040408@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2011 02:32 PM, Wolfgang Grandegger wrote:
> On 08/09/2011 08:17 PM, Scott Wood wrote:
>> On 08/09/2011 09:43 AM, Robin Holt wrote:
>>> In working with the socketcan developers, we have come to the conclusion
>>> the fsl-flexcan device tree bindings need to be cleaned up. 
>>> The driver does not depend upon any properties other than the required properties
>>> so we are removing the file.
>>
>> That is not the criterion for whether something should be expresed in
>> the device tree.  It's a description of the hardware, not a Linux driver
>> configuration file.  If there are integration parameters that can not be
>> inferred from "this is FSL flexcan v1.0", they should be expressed in
>> the node.
>>
>> Removing the binding altogether seems extreme as well -- we should have
>> bindings for all devices, even if there are no special properties.
> 
> Yes, of course. The commit message misleading. We do not intend to
> remove the binding but just a few unused and confusing properties.

Is it a matter of the current driver not caring, or the properties just
not making sense for any reasonable driver (ambiguous, inferrable from
the flexcan version, software configuration, etc)?

-Scott

