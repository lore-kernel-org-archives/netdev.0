From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: Submission #3  for S2io 10GbE driver
Date: Mon, 1 Mar 2004 07:24:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c3ffa1$48643490$7410100a@S2IOtech.com>
References: <4223A04BF7D1B941A25246ADD0462FF50115ADF9@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <sriram.rapuru@wipro.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <raghavendra.koushik@wipro.com>, <netdev@oss.sgi.com>,
        <ravinandan.arakali@s2io.com>
In-Reply-To: <4223A04BF7D1B941A25246ADD0462FF50115ADF9@blr-m3-msg.wipro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: raghavendra.koushik@wipro.com 
> [mailto:raghavendra.koushik@wipro.com] 
> Sent: Monday, March 01, 2004 5:05 AM
> To: leonid.grossman@s2io.com; netdev@oss.sgi.com; 
> ravinandan.arakali@s2io.com
> Cc: sriram.rapuru@wipro.com
> Subject: RE: Submission #3 for S2io 10GbE driver
> 
> 
> 
> Hi Leonid,
> 
> 
>    This automated signature will be gone from tomorrow. Our 
> IMG guys are working on it and hopefully by then all mails 
> going out from
> 
> the s2io guys will not have this "Confidentiality Notice" 
> :-). I have a few more questions to Jeff but I'am holding on 
> to them till this is addressed. Just wanted to keep you 
> posted on this issue.

Sounds good, thanks!
There are cases when the notice is required by Wipro of course, but in
general it's either a nuisance or plain illegal.
Let me know if you need any help from my end to get it removed;
alternative would be to use private (or s2io) addresses for 
Talking to open lists.

Leonid



> 
> Regards
> Koushik
> 
> 
> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> 
> Sent: Monday, March 01, 2004 12:24 PM
> To: Raghavendra Koushik (WT01 - EMBEDDED & PRODUCT 
> ENGINEERING SOLUTIONS)
> Cc: leonid.grossman@s2io.com; netdev@oss.sgi.com; 
> shemminger@osdl.org; hch@infradead.org; 
> ravinandan.arakali@s2io.com; raghavendra.koushik@s2io.com
> Subject: Re: Submission #3 for S2io 10GbE driver
> 
> 
> raghavendra.koushik@wipro.com wrote:
> > Jeff,
> >  Regarding Point # 37
> >
> 
> >
> 
> >>>37) kill all of this:
> >>>
> >>>+/*  OS related system calls */
> >>>+
> >>>+#ifndef readq
> >>>+static inline u64 read64(void *addr)
> >>>+{
> >>>+       u64 ret = 0;
> >>>+       ret = readl(addr + 4);
> >>>+       (u64) ret <<= 32;
> >>>+       (u64) ret |= readl(addr);
> >
> 
> > 	[....]
> >
> 
> > I agree that read/write(32,16,8) are not used so can be eliminated,
> 
> > but the read/write64 macros are essential because not all platforms
> 
> > have defined the readq and writeq system calls. i386 for example
> 
> > doesn't have readq/writeq and to write into the 64 bit registers of
> 
> > the NIC, I use 2 successive 32 bits (readl/writel) operation to
> 
> > achieve the 64 bit equivalent. This procedure does work on all the
> 
> > platforms that we have tested on.
> 
> The code should use the kernel API -- readq/writeq -- not 
> define its own
> 
> API.  With regards to the missing readq/writeq on some 
> architectures...
> 
> Short term, if some arches do not provide readq/writeq, 
> provide your own
> 
> definition (i.e. rename your write64 to a 
> conditionally-defined writeq).
> 
> Long term, all Linux platforms need to provide readq/writeq, 
> so we need
> 
> to modify the architectures with the missing pieces.
> 
> 
> > Confidentiality Notice
> >
> 
> > The information contained in this electronic message and any
> 
> > attachments to this message are intended for the exclusive 
> use of the
> 
> > addressee(s) and may contain confidential or privileged information.
> 
> > If you are not the intended recipient, please notify the sender at
> 
> > Wipro or Mailadmin@wipro.com immediately and destroy all copies of
> 
> > this message and any attachments.
> 
> Oh really?  ;-)  You should talk to your lawyers and sysadmins about
> 
> sending email to open source people and lists...
> 
> Regards,
> 
> 	Jeff
> 
> 
> 
> 
> Confidentiality Notice
> 
> 
> The information contained in this electronic message and any 
> attachments to this message are intended for the exclusive 
> use of the addressee(s) and may contain confidential or 
> privileged information. If you are not the intended 
> recipient, please notify the sender at Wipro or 
> Mailadmin@wipro.com immediately and destroy all copies of 
> this message and any attachments.
> 
