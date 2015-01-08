From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Thu, 8 Jan 2015 10:22:12 +0000
Message-ID: <20150108102212.GA27599@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <9c1b0b0acde09019acb61b9b1a4eb4b18c62642a.1420594925.git.tgraf@suug.ch>
 <CAEP_g=__Ssxj3B_0sbp5D+Gh8YmQ7ub9giK4A_QYWVmYctjm-w@mail.gmail.com>
 <20150107230155.GC21149@casper.infradead.org>
 <CAEP_g=_t_KMUdit7WUSg+OORh=FoQtzLyygaVMftyDV-tAxJvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41415 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbbAHKWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 05:22:15 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=_t_KMUdit7WUSg+OORh=FoQtzLyygaVMftyDV-tAxJvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 05:18pm, Jesse Gross wrote:
> On Wed, Jan 7, 2015 at 3:01 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > The encoding will be based on struct ovs_vxlan_opts which is extended
> > as needed by appending new members to the end of the struct. Parsers
> > will look at the provided length to see which fields are provided.
> 
> But this means that if there are two extensions that are conflicting
> or if one is retired you still need to carry the earlier members of
> the struct. Why not make them real netlink attributes?

I figured that due to the limited space available in the VXLAN header
the structure would never grow big. I have no problem converting this
to use Netlink attributes internally though. Will address this in v2.
