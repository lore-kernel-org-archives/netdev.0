From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/3] Documentation: dts: Update compatible field
 description for APM X-Gene
Date: Mon, 2 Mar 2015 14:17:34 +0000
Message-ID: <20150302141734.GC16779@leverpostej>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
 <1425067710-14879-2-git-send-email-isubramanian@apm.com>
 <20150227201516.GA30683@leverpostej>
 <CAKh23FmLE-s_C5YUjLTQLT0_P9DT6LzmaBxJPRWY4AwXK9jQNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"mlangsdo@redhat.com" <mlangsdo@redhat.com>,
	"patches@apm.com" <patches@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:47228 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbbCBOSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 09:18:03 -0500
Content-Disposition: inline
In-Reply-To: <CAKh23FmLE-s_C5YUjLTQLT0_P9DT6LzmaBxJPRWY4AwXK9jQNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 11:58:28PM +0000, Iyappan Subramanian wrote:
> On Fri, Feb 27, 2015 at 12:15 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Feb 27, 2015 at 08:08:28PM +0000, Iyappan Subramanian wrote:
> >> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> >> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> >> Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
> >> ---
> >>  Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> >> index cfcc527..5355996 100644
> >> --- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> >> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> >> @@ -4,7 +4,8 @@ Ethernet nodes are defined to describe on-chip ethernet interfaces in
> >>  APM X-Gene SoC.
> >>
> >>  Required properties for all the ethernet interfaces:
> >> -- compatible: Should be "apm,xgene-enet"
> >> +- compatible: Should be "apm,xgene-enet", "apm,xgene1-sgenet" or
> >> +  "apm,xgene1-xgenet"
> >
> > Please format this as a list. It'll be easier to read, and you can add
> > more later.
> 
> Thanks.  I will do that.
> 
> >
> > What are the diffences between these variants?
> 
> apm,xgene-enet - binding for RGMII based 1G interface
> apm,xgene1-sgenet - binding for SGMII based 1G interface
> apm,xgene1-xgenet - binding for XFI based 10G interface

I see. If you could keep notes to this effect in the list, that would
help to keep this obvious.

Thanks,
Mark.
