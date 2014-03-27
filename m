From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 11:02:23 +0000
Message-ID: <20140327110223.GA1615@casper.infradead.org>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55412 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034AbaC0LC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:02:27 -0400
Content-Disposition: inline
In-Reply-To: <5333FD12.9060404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 at 06:27am, Jamal Hadi Salim wrote:
> On 03/27/14 03:21, Jiri Pirko wrote:
> >Wed, Mar 26, 2014 at 10:44:31PM CET, jhs@mojatatu.com wrote:
> 
> >Well, I think there are 2 main models to be considered:
> >1. OSV-like model, where everything is flows and that is the OneWay(tm)
> >    mode you mentioned :)
> >2. clasic switch setting-like model where you manually set up vlans,
> >    lag, whatever.
> >
> >The phase one for me is 1. and that is what I'm trying to resolve with
> >this patchset.
> >
> > From what I understand from the discussion, 2. is likely the model you
> >have in mind.
> >
> 
> In my opinion there is no difference when setting the ACL table(s).
> We are going to need your .ndo for more than flows. Something
> in the stack is going to have to talk to those .ndo interfaces
> (I keep bringing up the concept of routing code for example).
> What i meant by no OneWay is i think it will depend on the
> chip - some will require more work than other. I do believe it
> is a longer discussion needed than the port resolving.

There is definitely need beyond an ndo that is capable of
adding flows. You mention routes. Another example would be
devices capable of offloading iptables & nft rules.

But wouldn't you want to introduce an additional ndo to
cover these?

What speaks against going with what Jiri proposes and adjust
& extend as needed as we go along?
