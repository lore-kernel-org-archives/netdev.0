From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 6 Sep 2013 06:28:01 +0000
Message-ID: <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
References: <1378447278-13998-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>,<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23266 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738Ab3IFG2D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 02:28:03 -0400
In-Reply-To: <20130905231436.761d03c3@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep 5, 2013, at 11:15 PM, "Stephen Hemminger" <stephen@networkplumber.org<mailto:stephen@networkplumber.org>> wrote:

Dumb question why is this named Kbuild instead of Makefile like almost
every other network driver?

All the new kids are doing it, we'll at least that is what I thought when I made it.

Re-reading https://www.kernel.org/doc/Documentation/kbuild/makefiles.txt

I see that Makefile is preferred but Kbuild overrides Makefile.

Either way works, but I would prefer not to rename it at this point but would gladly do so in a follow up patch
