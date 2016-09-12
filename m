From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH V3] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Mon, 12 Sep 2016 08:38:43 -0500
Message-ID: <20160912133843.GA25149@rob-hp-laptop>
References: <20160901190216.5643-1-swarren@wwwdotorg.org>
 <038d710a-f8fe-b569-11ee-2dc4c3ec6d28@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>,
        Lars Persson <lars.persson@axis.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, Stephen Warren <swarren@nvidia.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35413 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758069AbcILNip (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 09:38:45 -0400
Content-Disposition: inline
In-Reply-To: <038d710a-f8fe-b569-11ee-2dc4c3ec6d28@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 11:49:31AM -0600, Stephen Warren wrote:
> On 09/01/2016 01:02 PM, Stephen Warren wrote:
> >From: Stephen Warren <swarren@nvidia.com>
> >
> >The Synopsys DWC EQoS is a configurable IP block which supports multiple
> >options for bus type, clocking and reset structure, and feature list.
> >Extend the DT binding to define a "compatible value" for the configuration
> >contained in NVIDIA's Tegra186 SoC, and define some new properties and
> >list property entries required by that configuration.
> >
> >Signed-off-by: Stephen Warren <swarren@nvidia.com>
> >---
> >v3:
> >* Document legacy clock-names entries separately, and make it obvious
> >  they're deprecated.
> >* Reword the description of the "rx" clock to better describe the HW.
> >* Add some extra guidance for future extensions of the binding to cover
> >  configurations where additional RX clocks are required.
> >* Explicitly document the list of clocks and resets for every compatible
> >  value; don't miss any out.
> 
> Rob, Mark,
> 
> Does this version look good (Lars already acked it)? If so, if you could ack
> it that'd be great; I want to send some U-Boot drivers that use this
> binding, but don't want to do so before I know it's final.

Applied.

Rob
