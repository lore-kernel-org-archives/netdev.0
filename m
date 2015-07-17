From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 22/22] openvswitch: Use regular GRE net_device
 instead of vport
Date: Fri, 17 Jul 2015 12:58:53 +0200
Message-ID: <20150717105853.GB18033@pox.localdomain>
References: <cover.1436537414.git.tgraf@suug.ch>
 <74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
 <20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
 <20150716145246.GC22603@pox.localdomain>
 <CALnjE+omzvWop3T2bD_Yp9gW3XN-9NbeEnCmh615iNqJH2dvog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>, rshearma@brocade.com,
	ebiederm <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, tom@herbertland.com,
	Eric Dumazet <edumazet@google.com>,
	Ji???? P??rko <jiri@resnulli.us>, marcelo.leitner@gmail.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Justin Pettit <jpettit@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35753 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757752AbbGQK64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 06:58:56 -0400
Received: by wibxm9 with SMTP id xm9so35948096wib.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 03:58:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+omzvWop3T2bD_Yp9gW3XN-9NbeEnCmh615iNqJH2dvog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/15 at 02:36pm, Pravin Shelar wrote:
> On Thu, Jul 16, 2015 at 7:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > I'm inclined to change this and use an in-kernel API as well to
> > create the net_device just like VXLAN does in patch 21.
> >
> > Pravin, what do you think?
> 
> About the vxlan APIs we also need to direct netlink interface for
> userspace to configure vxlan device. This will allow us to remove
> vxlan compat code from ovs vport-netdev.c in future.

Do you mean creating the tunnel devices from user space? This would
break existing users of the OVS Netlink interface. How do you want
to prevent that?
