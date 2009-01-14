From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Wed, 14 Jan 2009 18:00:21 +0000
Message-ID: <1231956021.3010.35.camel@achroite>
References: <1231951375.11301.126.camel@lb-tlvb-eliezer>
	 <1231952234.3010.24.camel@achroite>
	 <1231954948.11301.158.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34152 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760AbZANSA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 13:00:26 -0500
In-Reply-To: <1231954948.11301.158.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 19:42 +0200, Eilon Greenstein wrote:
> On Wed, 2009-01-14 at 08:57 -0800, Ben Hutchings wrote:
> > On Wed, 2009-01-14 at 18:42 +0200, Eilon Greenstein wrote:
> > > When TPA (HW GRO) is used, the GSO_TYPE should be set
> > [...]
> > 
> > No it shouldn't.  That is for the output path only.
> > 
> 
> Right - but it was an issue with forwarding

You can't use LRO together with forwarding/bridging unless you replicate
what Herbert Xu has done to allow reconstruction of the original frames.
Setting gso_type is a hack which you may or may not get away with,
depending on the output device's capabilities.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

