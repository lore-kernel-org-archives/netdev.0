From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 09/26] e1000: unify WoL capability detection code
Date: Tue, 29 Aug 2006 16:51:13 -0400
Message-ID: <44F4A8C1.9020301@pobox.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164434.6872.82138.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48524 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965339AbWH2UvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:51:16 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060829164434.6872.82138.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> WoL is constantly giving problems and needed a rewrite. Consolidates
> all WoL capabilities into a single function, and disables WoL for all
> other ports on the device except for port A.

Is this a behavior change that affects users in the field?

i.e. if they are using WoL via port B, and upgrade to this driver, their 
setup suddenly breaks, right?

	Jeff



