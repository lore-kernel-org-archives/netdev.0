From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Thu, 15 Jan 2015 00:01:25 +0000
Message-ID: <20150115000125.GG2105@casper.infradead.org>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com>
 <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
 <54B6FD60.8020106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34324 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbAOABd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 19:01:33 -0500
Content-Disposition: inline
In-Reply-To: <54B6FD60.8020106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 03:36pm, John Fastabend wrote:
> On 01/14/2015 03:22 PM, Arad, Ronen wrote:
> >What is the purpose of the above two lines (not changed by the patch)?
> >They seem to copy over the flags with the successfully applied cases
> >(MASTER and/or SELF) flags cleared back into the incoming netlink message.
> >I could not figure any place where the modified flags attribute is used
> 
> This allows userspace to learn which operation failed when it is an
> operation to set both the software bridge via BRIDGE_FLAGS_MASTER and
> the the hardware via BRIDGE_FLAGS_SELF. When we get the error back
> software looks at the flags to figure out how to recover/retry/etc.

The intent of including the original message in the error Netlink
message was originally to track the request that lead to the error ;-)
