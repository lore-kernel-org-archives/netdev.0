From: Joe Perches <joe@perches.com>
Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 06 Sep 2013 11:20:15 -0700
Message-ID: <1378491615.19204.10.camel@joe-AO722>
References: <1378447278-13998-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 ,<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
	 <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
	 <1378450038.19204.6.camel@joe-AO722>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D5C3B0A3D@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40053 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750833Ab3IFSUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 14:20:16 -0400
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D5C3B0A3D@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 17:28 +0000, Williams, Mitch A wrote:
> My goal was to make our out-of-tree driver as close as possible -
> including the makefiles - to the upstream driver. Doing this makes it
> simpler for us to backport and forward-port patches. It makes it less
> confusing for us when we're moving from one environment to the other.

I think using things like

#define i40e_memset memset

is just odd.
