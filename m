From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: Topic:  Remote DMA network technologies
Date: Mon, 28 Mar 2005 16:54:48 -0800
Message-ID: <1112057688.5088.59.camel@beastie>
References: <67D69596DDF0C2448DB0F0547D0F947E01781DEF@yogi.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi@googlegroups.com
In-Reply-To: <67D69596DDF0C2448DB0F0547D0F947E01781DEF@yogi.asicdesigners.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 16:44 -0800, Asgeir Eiriksson wrote:
> 
> 
> > -----Original Message-----
> > From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> > Behalf Of Dmitry Yusupov
> > Sent: Monday, March 28, 2005 12:49 PM
> > To: open-iscsi@googlegroups.com
> > Cc: David S. Miller; mpm@selenic.com; andrea@suse.de;
> > michaelc@cs.wisc.edu; James.Bottomley@HansenPartnership.com;
> ksummit-2005-
> > discuss@thunk.org; netdev@oss.sgi.com
> > Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit
> > ProposedTopics
> > 
> > Basically, HW offloading all kind of is a different subject.
> > Yes, iSER/RDMA/RNIC will help to avoid bunch of problems but at the
> same
> > time will add bunch of new problems. OOM/deadlock problem we are
> > discussing is a software, *not* hardware related.
> > 
> > If you have plans to start new project such as SoftRDMA than yes. lets
> > discuss it since set of problems will be similar to what we've got
> with
> > software iSCSI Initiators.
> > 
> > I'm not a believer in any HW state-full protocol offloading
> technologies
> > and that was one of my motivations to initiate Open-iSCSI project to
> > prove that performance is not an issue anymore. And we succeeded, by
> > showing comparable to iSCSI HW Initiator's numbers.
> > 
> 
> Dmitry
> 
> Care to be more specific about the performance you achieved?
> 
> You might want to contrast your numbers to veritest verified numbers of
> 800+ MBps and 600+KOPS achieved by Chelsio HBA with stateful offload
> using either 1500B or 9KB MTU (for full detail see Veritest report at
> http://www.chelsio.com/technology/Chelsio10GbE_iSCSI_report.pdf)
> 
> 'Asgeir

I changed the subject, btw.

In your paper. Its 28 M$ Initiator against one iSCSI Target on top of
Chelsio HBA. Now prove me that Chelsio HBA as an Initiator can do
somewhat close to 100K IOPS with regular Linux SCSI-MidLayer...

Regards.
Dmitry
