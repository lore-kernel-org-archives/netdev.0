From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/6] openvswitch: Rename GENEVE_TUN_OPTS() to
 TUN_METADATA_OPTS()
Date: Mon, 12 Jan 2015 23:00:01 +0000
Message-ID: <20150112230001.GD11857@casper.infradead.org>
References: <cover.1421064100.git.tgraf@suug.ch>
 <c55f879e5dedb8ec3d6d06ce7d9d095e787e1c77.1421064100.git.tgraf@suug.ch>
 <CAEP_g=8GfXi-nhQ+n5P+QuxVoV9abm+2VsonvLQ1hCNP-oONNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48129 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbALXAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:00:02 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8GfXi-nhQ+n5P+QuxVoV9abm+2VsonvLQ1hCNP-oONNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 01:38pm, Jesse Gross wrote:
> On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index d1eecf7..8980d32 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c
> > +static int validate_and_copy_geneve_opts(struct sw_flow_key *key)
> > +{
> 
> This function doesn't actually do any copying, so maybe there is a
> more descriptive name for it?

Sure, will rename.
