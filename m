From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 14:19:59 -0700
Message-ID: <20110926141959.58d310c0@nehalam.linuxnetplumber.net>
References: <1317055319.2773.41.camel@bwh-desktop>
	<20110926094719.0cb6c296@nehalam.linuxnetplumber.net>
	<184D23435BECB444AB6B9D4630C8EC83028F8A71@XMB-RCD-303.cisco.com>
	<20110926.170049.1943390151354224651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, bhutchings@solarflare.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46224 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab1IZVUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 17:20:02 -0400
In-Reply-To: <20110926.170049.1943390151354224651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2011 17:00:49 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: "Christian Benvenuti (benve)" <benve@cisco.com>
> Date: Mon, 26 Sep 2011 15:54:53 -0500
> 
> > Does it mean that a Netlink interface becomes official (and backward
> > compatibility should not be broken) only once iproute2 starts
> > supporting it?
> 
> It needs to be analyzed on a case-by-case basis.  Sometimes we can quickly
> fix a poorly designed netlink interface is no major tool takes on use of
> the feature.

If an interface changes before an official release, there is no
problem. I.e. if an interface goes through multiple versions while
in net-next (or a bug fix during 3.X-rc*) that's fine.
