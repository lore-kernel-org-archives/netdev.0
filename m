From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] bnx2: Add support for CNIC driver.
Date: Thu, 22 May 2008 22:32:09 -0700
Message-ID: <20080523053209.GD8612@linux.vnet.ibm.com>
References: <20080523034522.GA8612@linux.vnet.ibm.com> <1551EAE59135BE47B544934E30FC4FC002AABD1C@nt-irva-0751.brcm.ad.broadcom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, michaelc@cs.wisc.edu,
	Anil Veerabhadrappa <anilgv@broadcom.com>,
	netdev <netdev@vger.kernel.org>, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABD1C@nt-irva-0751.brcm.ad.broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 22, 2008 at 09:52:48PM -0700, Michael Chan wrote:
> Paul E. McKenney wrote:
> 
> > So if a second CNIC driver attempts to register, it gets -EBUSY or
> > something, right?
> 
> There is only one CNIC driver and it will only register once per
> BNX2 netdevice.

I would nevertheless recommend keeping an error check...

> > > You are right.  We should just unconditionally set up the IRQ
> > > information without checking for c_ops.  The data 
> > structures we set up
> > > below are owned by us.
> > 
> > OK.  Hmmm....  You cannot even get away with sarcasm these days!  ;-)
> 
> Hmm, not sure what's the sarcasm.  The code here is trying to set up
> the IRQ information so that CNIC driver can see it.  Even if the CNIC
> driver is deregistering or was never registered, it doesn't hurt to
> set up that information.

The sarcasm was that I really didn't expect you to simply be able to
remove the check.  ;-)

> Anyway, I'll add some comments to the code to explain this better when
> I respin.
> 
> > Very good.  Could you please add a comment to that effect?  Otherwise
> > people search for what data structure is being freed up.
> > 
> 
> Will do.  Thanks.

Sounds good!

							Thanx, Paul
