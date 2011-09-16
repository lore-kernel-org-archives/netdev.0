From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: re add support for bcm5750
Date: Fri, 16 Sep 2011 09:28:24 -0700
Message-ID: <20110916162824.GB27116@mcarlson.broadcom.com>
References: <1280784368-4226-8-git-send-email-mcarlson@broadcom.com>
 <20110906170343.09252578@schatten.dmk.lab>
 <20110907012515.GA9038@mcarlson.broadcom.com>
 <20110907203646.2a7b7833@schatten.dmk.lab>
 <CAA7bCn4NTSppmAph9pxykpEfYT_tYoBFV8zReaKFgJqcu6=t7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Florian Mickler" <florian@mickler.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Francesco Piccinno" <stack.box@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA7bCn4NTSppmAph9pxykpEfYT_tYoBFV8zReaKFgJqcu6=t7Q@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 16, 2011 at 06:39:30AM -0700, Francesco Piccinno wrote:
> I have contacted Broadcom asking for support and apparently there is
> no way to fix the problem. Now I have a couple of questions: the use
> of tg3 driver without a firmware expose the NIC to some risks or not?
> And is there any chance to have the PCI IDs added back to tg3 module?
> I do not want to modify and recompile the module at every version
> bump.
> 
> Thanks for the support :)

That's the plan.  It's on my TODO list to add support back in.

> --
> Best regards,
> Francesco Piccinno
> 
> 
> 
> On Wed, Sep 7, 2011 at 8:36 PM, Florian Mickler <florian@mickler.org> wrote:
> > On Tue, 6 Sep 2011 18:25:15 -0700
> > "Matt Carlson" <mcarlson@broadcom.com> wrote:
> >
> >> On Tue, Sep 06, 2011 at 08:03:43AM -0700, Florian Mickler wrote:
> >> > Hi,
> >> >
> >> > in https://bugzilla.kernel.org/show_bug.cgi?id=42132 Francesco wrote:
> >> >
> >> > > I have a notebook (HP TC4400) which has a BCM5750 ethernet card inside. The
> >> > > ouput of lspci is:
> >> > >
> >> > > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme BCM5750M
> >> > > Gigabit Ethernet [14e4:167c]
> >> > >
> >> > > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support for this
> >> > > device. I wish to have the support for this network card back again. Thanks!
> >>
> >> Hi Florian. ??Are you experiencing the same problem? ??We found that
> >> Francesco's problem was that the firmware of his device was missing. ??Do
> >> you see :
> >>
> >> eth0: No firmware running
> >>
> >> messages?
> >>
> >
> > Hi Matt!
> > No, I was just browsing the regression list and found this entry but
> > couldn't associate any action with it.
> >
> > This clears that up, thanks for the information and I will close this
> > bug.
> >
> > Regards,
> > Flo
> >
> 
