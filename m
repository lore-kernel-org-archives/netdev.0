From: Hank Janssen <hjanssen@microsoft.com>
Subject: RE: Process for subsystem maintainers to get Hyper-V code out of
 staging. - CORRECTED RECIPIENTS
Date: Wed, 16 Feb 2011 17:43:34 +0000
Message-ID: <8AFC7968D54FB448A30D8F38F259C56233F98FDA@TK5EX14MBXC114.redmond.corp.microsoft.com>
References: <8AFC7968D54FB448A30D8F38F259C56233F957D3@TK5EX14MBXC114.redmond.corp.microsoft.com>
 <4D59CCAD.90503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	ide <linux-ide@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Hashir Abdi <habdi@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"gregkh@suse.de\" \"" <gregkh@suse.de>
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <4D59CCAD.90503@gmail.com>
Content-Language: en-US
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Robert Hancock [mailto:hancockrwd@gmail.com]
> Sent: Monday, February 14, 2011 4:46 PM
> On 02/14/2011 05:42 PM, Hank Janssen wrote:
> >
> > MY APOLOGIES-I made a typo on James email address. I corrected it and
> resend.
> > Sorry for the double email.
> >
> >
> > Stephen/James/David,
> >
> > Greetings to you all. As you might be aware, we submitted Hyper-V
> drivers to the kernel 2009.
> > We have been extending these drivers with additional functionality
> and our primary focus now
> > is doing the work needed to exit the staging area.
> >
> > To give you some background, the following are Hyper-V specific Linux
> drivers:
> >
> >                  hv_vmbus           The vmbus driver that is the
> bridge between guest and the
> > 			host
> >                  hv_storvsc          The SCSI device driver
> >                  hv_blkvsc            The IDE driver
> 
> Given that the IDE subsystem (drivers/ide) is currently in
> maintenance-only mode, and isn't used by modern distributions, you
> likely want to make this a libata driver instead.
> 
> Though, from what's in current git, it's not clear to me what the HV
> IDE
> (and SCSI) drivers are attempting to do. Is it really something that
> looks like an IDE controller from the guest OS point of view? If not,
> then having it as an IDE driver would be the wrong thing to do, it
> should be more of a generic block driver. In that case, then, why are
> there both SCSI and IDE drivers in the first place?
> 

Robert,

Thank you very much for your responses, today Hyper-V host only supports 
IDE and SCSI, and the code was initially written against 2.6.9 kernel.

Hyper-V still treats them a separate interface and is designed to emulate
A pretty old BIOS.

What my approach will be is to dig into libsata (something I have not
Much knowledge of) and see if we can use it and find a way to more sanely
Merge the behavior of Hyper-V's IDE and SCSI.

Hank.

