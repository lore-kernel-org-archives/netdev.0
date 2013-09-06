From: Joe Perches <joe@perches.com>
Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Thu, 05 Sep 2013 23:47:18 -0700
Message-ID: <1378450038.19204.6.camel@joe-AO722>
References: <1378447278-13998-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 ,<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
	 <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45250 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750775Ab3IFGrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 02:47:19 -0400
In-Reply-To: <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 06:28 +0000, Brandeburg, Jesse wrote:
> On Sep 5, 2013, at 11:15 PM, "Stephen Hemminger" <stephen@networkplumber.org<mailto:stephen@networkplumber.org>> wrote:
> 
> Dumb question why is this named Kbuild instead of Makefile like almost
> every other network driver?
> 
> All the new kids are doing it, we'll at least that is what I thought when I made it.
> 
> Re-reading https://www.kernel.org/doc/Documentation/kbuild/makefiles.txt
> 
> I see that Makefile is preferred but Kbuild overrides Makefile.
> 
> Either way works, but I would prefer not to rename it at this point but would gladly do so in a follow up patch

Please do.

I suppose it makes _some_ sense to use Kbuild in the
include paths but I think Makefile in places where
compilations are done is better.
