From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Sun, 11 Jun 2006 19:08:49 -0400
Message-ID: <20060611230849.GC13139@redhat.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611223140.GB1163@skunkworks.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Faidon Liambotis <faidon@cube.gr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49845 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751096AbWFKXI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 19:08:57 -0400
To: Kyle McMartin <kyle@mcmartin.ca>
Content-Disposition: inline
In-Reply-To: <20060611223140.GB1163@skunkworks.cabal.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 11, 2006 at 06:31:40PM -0400, Kyle McMartin wrote:
 > On Sun, Jun 11, 2006 at 06:40:54PM -0400, Dave Jones wrote:
 > > Under hostap, it's a brick, it won't even report any scanning results.
 > > 
 > 
 > Did you switch it into managed mode? The hostap driver, iirc, defaults
 > to running in master (AP) mode.

Ah, yes, that gets it able to scan again, thanks.
This is another gotcha that is going to prevent a smooth transition
from orinoco->hostap for end users though.

		Dave

-- 
http://www.codemonkey.org.uk
