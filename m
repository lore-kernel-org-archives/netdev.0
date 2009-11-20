From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Subject: RE: Compile Error for TI Davinci
Date: Sat, 21 Nov 2009 01:26:49 +0530
Message-ID: <FCCFB4CDC6E5564B9182F639FC35608702FA751AFB@dbde02.ent.ti.com>
References: <FCCFB4CDC6E5564B9182F639FC35608702FA751A01@dbde02.ent.ti.com>
 <20091120.095000.265125164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Subrahmanya, Chaithrika" <chaithrika@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:35753 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234AbZKTT4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 14:56:52 -0500
In-Reply-To: <20091120.095000.265125164.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, November 20, 2009 11:20 PM
> To: Govindarajan, Sriramakrishnan
> Cc: netdev@vger.kernel.org; davinci-linux-open-
> source@linux.davincidsp.com; Subrahmanya, Chaithrika
> Subject: Re: Compile Error for TI Davinci
> 
> From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
> Date: Fri, 20 Nov 2009 17:36:38 +0530
> 
> > Patch for "TI DaVinci EMAC: Clear statistics register properly"(commit-
> 0fe7463a35aadfaf22d1ca58325ab3851b8d757c on net-next) has dependency on
> > Patch "TI DaVinci EMAC: Minor macro related updates "(commit -
> 69ef9694099802f7feeb23182dfb869e7c5f76f0 on net-next).
> >
> > The first patch has been pushed upstream while the later still remains
> on
> > Net-next. Due to the dependency between these two, we are seeing
> compilation
> > Failure when we build for Davinci.
> >
> > Can you please push "TI DaVinci EMAC: Minor macro related updates" -
> 69ef9694099802f7feeb23182dfb869e7c5f76f0 up-stream .
> 
> This should not be happening, because yesterday I merged Linus's
> tree into net-2.6 and afterwards I merged net-2.6 into net-next-2.6
> 
> Please verify that the problem still occurs.
[Sriram]  David the commit " TI DaVinci EMAC: Minor macro related updates" exists only on the net-next-2.6 git. As mentioned in my earlier email, subsequent patch " DaVinci EMAC: Clear statistics register properly" is dependent on this  and is reflected in the net-2.6 and Linus's GIT. Hence compilation for Davinci would fail on both net-2.6 and Linus's GIT

I just verified the failure by building against the tip of Linus's GIT
Regards
Sriram

