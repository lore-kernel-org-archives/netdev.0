From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Offloading features in VLAN interfaces
Date: Fri, 29 Sep 2006 20:33:34 -0700
Message-ID: <20060929203334.6ac78838@localhost.localdomain>
References: <b54af0b00609291721u16acb2f1ma918adec9b2e782b@mail.gmail.com>
	<b54af0b00609291725t55ac0a84pf86525ef0a31f44e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olivier.crameri@gmail.com, netdev@vger.kernel.org,
	"Yoshio Turner" <yoshiotu@hpl.hp.com>,
	"Santos, Jose Renato G" <joserenato.santos@hp.com>,
	"Janakiraman, John" <john.janakiraman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51664 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750730AbWI3DkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 23:40:10 -0400
To: olivier.crameri@epfl.ch
In-Reply-To: <b54af0b00609291725t55ac0a84pf86525ef0a31f44e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006 17:25:35 -0700
"Olivier Crameri" <olivier.crameri@gmail.com> wrote:

> Same thing but with the patch this time.
> 
> Sorry about that,
> Olivier Crameri
> 
> On 9/29/06, Olivier Crameri <olivier.crameri@gmail.com> wrote:
> > Hi,
> >
> > after running some experiments, we realised that using VLAN support in
> > Linux caused some overhead. It turned out to be that the offloading
> > features of our NIC (tso, sg, checksum offloading) were not beeing
> > used.
> >
> > After digging a little bit in the code, we realised that the VLAN code
> > did not set the features parameter of the net_device structure for the
> > virtual interface. Attached is a patch with a suggested solution to
> > this problem.
> >
> > Please let us know if this is an acceptable patch.
> >
> > Thanks,
> > Olivier Crameri, HP Labs
> >

Patch needs to include "Developer's Certificate of Origin"
see Documentation/SubmittingPatches section 11.

Patch should not be sent as an attachment (if at all possible).

Skip the marque comment. It is standard practice now to use the revision
control system change log for attribution.

Please handle all the current offload features including GSO.
