From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Opportunity to backport pch_gbe patches to stable 3.2.x
Date: Wed, 19 Sep 2012 21:49:05 +0100
Message-ID: <20120919204905.GE29217@decadent.org.uk>
References: <505A11E2.8000403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Erwan Velu <erwanaliasr1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33057 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751697Ab2ISUtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:49:09 -0400
Content-Disposition: inline
In-Reply-To: <505A11E2.8000403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 19, 2012 at 08:41:38PM +0200, Erwan Velu wrote:
> Hi there,
> 
> I'm using on a daily use and in production 3.2.x kernels (.29 currently) on a Kontron Nano-etx board that features the pch_gbe network driver.
> 
> I've been experiencing lots of troubles on this kernel series but since I've backported the following commits back to my 3.2.x, it works far better.
> 
> So from the history of next the following commits apply perfectly and runs very well.
> 
> I do think that other users of pch_gbe will appreciate this.
> 
> 1a0bdadb4e36abac63b0a9787f372aac30c11a9e
[...]

This first one is adding support for an extra hardware feature, which
is not suitable material for stable.  Please pick out only the
important bug fixes, per Documentation/stable_kernel_rules.txt.

If you want the driver to be completely backported, look at the
compat-drivers project
<https://backports.wiki.kernel.org/index.php/Documentation/compat-drivers>
or distribution kernels instead of stable.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
