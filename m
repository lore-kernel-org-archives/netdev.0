From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/3] dtb: change binding name to match with newer
 firmware DT
Date: Mon, 2 Mar 2015 14:48:58 +0000
Message-ID: <20150302144858.GG16779@leverpostej>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
 <1425067710-14879-3-git-send-email-isubramanian@apm.com>
 <4061014.S4PDWltU3G@wuerfel>
 <CAKh23Fm5HpNEfs40RTf_XtQ6ris5cCheAcY1WdLND04AwsvdSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"mlangsdo@redhat.com" <mlangsdo@redhat.com>,
	patches <patches@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:47413 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbbCBOt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 09:49:27 -0500
Content-Disposition: inline
In-Reply-To: <CAKh23Fm5HpNEfs40RTf_XtQ6ris5cCheAcY1WdLND04AwsvdSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 11:52:54PM +0000, Iyappan Subramanian wrote:
> On Fri, Feb 27, 2015 at 12:33 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Friday 27 February 2015 12:08:29 Iyappan Subramanian wrote:
> >> diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> >> index f1ad9c2..a857794 100644
> >> --- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
> >> +++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> >> @@ -622,7 +622,7 @@
> >>                 };
> >>
> >>                 sgenet0: ethernet@1f210000 {
> >> -                       compatible = "apm,xgene-enet";
> >> +                       compatible = "apm,xgene1-sgenet";
> >>                         status = "disabled";
> >>                         reg = <0x0 0x1f210000 0x0 0xd100>,
> >>                               <0x0 0x1f200000 0x0 0Xc300>,
> >>
> >
> > This will break booting the new dtb on older kernels, right?
> 
> This will not break booting older kernels.  In fact, this will fix it,
> by having the specific binding,
> older kernel that does not have support for these interfaces, will not
> call probe.
> 
> For example, 3.17 kernel that does not have support for SGMII based 1G
> and XFI 10G interfaces
> will not probe these interfaces when booted with newer dtb.

I'm guessing that in the existing DTBs, these nodes are always disabled?

If that's the case then we don't have a problem; we'll never probe these
nodes for an existing DTB.

Mark.
