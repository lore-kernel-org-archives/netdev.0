From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Topic:  Remote DMA network technologies
Date: Tue, 29 Mar 2005 11:21:35 -0800
Message-ID: <200503291921.j2TJLeDD018072@guinness.s2io.com>
References: <1112057688.5088.59.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <mpm@selenic.com>,
        <andrea@suse.de>, <michaelc@cs.wisc.edu>,
        <James.Bottomley@HansenPartnership.com>,
        <ksummit-2005-discuss@thunk.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>, <open-iscsi@googlegroups.com>
In-reply-to: <1112057688.5088.59.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of Dmitry Yusupov
> Sent: Monday, March 28, 2005 4:55 PM
> To: open-iscsi@googlegroups.com
> Cc: David S. Miller; mpm@selenic.com; andrea@suse.de;
> michaelc@cs.wisc.edu; James.Bottomley@HansenPartnership.com; ksummit-2005-
> discuss@thunk.org; netdev@oss.sgi.com
> Subject: Re: Topic: Remote DMA network technologies
> 
> On Mon, 2005-03-28 at 16:44 -0800, Asgeir Eiriksson wrote:
> > Care to be more specific about the performance you achieved?
> >
> > You might want to contrast your numbers to veritest verified numbers of
> > 800+ MBps and 600+KOPS achieved by Chelsio HBA with stateful offload
> > using either 1500B or 9KB MTU (for full detail see Veritest report at
> > http://www.chelsio.com/technology/Chelsio10GbE_iSCSI_report.pdf)
> >
> > 'Asgeir

FYI, 
http://biz.yahoo.com/prnews/050329/cgtu006.html?.v=4

The actual whitepaper with performance results is on our site. In short, it
shows that it's fine to run sw iSCSI over 10GbE NIC with Linux-supported
stateless offloads (receive side could use more of these though :-)), on a
generic Opteron box. 
  
Leonid

> 
> I changed the subject, btw.
> 
> In your paper. Its 28 M$ Initiator against one iSCSI Target on top of
> Chelsio HBA. Now prove me that Chelsio HBA as an Initiator can do
> somewhat close to 100K IOPS with regular Linux SCSI-MidLayer...
> 
> Regards.
> Dmitry
> 
> 
