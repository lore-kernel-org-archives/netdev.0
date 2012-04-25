From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net 1/2] e1000e: MSI interrupt test failed, using legacy
 interrupt
Date: Wed, 25 Apr 2012 16:59:07 +0100
Message-ID: <1335369547.2602.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1335333314-6814-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Prasanna S Panchamukhi <ppanchamukhi@riverbed.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10933 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754532Ab2DYP7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 11:59:25 -0400
In-Reply-To: <1335333314-6814-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 22:55 -0700, Jeff Kirsher wrote:
> From: Prasanna S Panchamukhi <ppanchamukhi@riverbed.com>
> 
> Following logs where seen on Systems with multiple NICs,
> while using MSI interrupts as shown below:
[...]
> This patch fixes this problem by increasing the msleep from 50 to 100.
[...]

It probably doesn't, in general.  The out-of-tree version of the sfc
driver used to perform an interrupt test during probe, and after fixing
it up repeatedly I eventually had to remove it completely as there are
so many ways to get a false negative.  Also see the related commit
93e5dfa59b0e26a145a8adce5c9edf50bdaef4c7 ('sfc: Raise self-test
timeouts').

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
