From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 2/8] maintainers: update with official intel support
 link, new maintainer
Date: Tue, 23 Oct 2012 06:25:01 -0700
Message-ID: <1350998701.7502.42.camel@joe-AO722>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46139 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756896Ab2JWNZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 09:25:03 -0400
In-Reply-To: <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 03:24 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Add an official link which is designed to guide the user to the appropriate
> support resource (be it community, OEM, Intel phone, Intel email, etc)
> 
> Add the current e1000 maintainer to the list of Intel maintainers.

Hi Jeff.

I think it's unwise to have 10 named maintainers for all
the intel ethernet drivers if there are specialists
maintainers.

Maybe it'd be better to break out these sub-maintainers
into specific driver sections with you as the overall
maintainer.

Maybe add an internal exploder to get all the various
maintainers on a list if everyone really looks at all
patches to intel drivers.

Something like:

INTEL ETHERNET DRIVERS
M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
M:	Intel Linux Support <linux.drivers@intel.com>
T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git
T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
S:	Supported
F:	drivers/net/ethernet/intel/

INTEL ETHERNET E1000 DRIVER
M:	Tushar Dave <tushar.n.dave@intel.com>
S:	Supported
F:	drivers/net/ethernet/intel/e1000/
F:	Documentation/networking/e1000.txt

etc...
