From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 19:41:37 +0000
Message-ID: <20150114194137.GC2105@casper.infradead.org>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	john.fastabend@gmail.com, jhs@mojatatu.com, sfeldma@gmail.com,
	jiri@resnulli.us, wkok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32855 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbbANTll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:41:41 -0500
Content-Disposition: inline
In-Reply-To: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/15 at 10:48pm, roopa@cumulusnetworks.com wrote:
> 2) Generate one notification from master and the other notification from
>    self (This seems to be ideal):
>      For master: the master driver will send notification (bridge in this
> 	example)
>      For self: the self driver will send notification (rocker in the above
> 	example. It can use helpers from rtnetlink.c to do so. Like the
> 	ndo_dflt_bridge_getlink api).
> 
> This patch implements 2) (leaving the 'rtnl_bridge_notify' around to be used
> with 'self').
> 
> CC'ing others who might be affected by this change for review.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

I haven't digested this line by line yet but I agree that what you
describe above would be a good end state.

If I read the patch correctly then we would omit one notification
for the master case. Were both notifications exactly identical
previously?

This has the chance of breaking existing users terribly.
