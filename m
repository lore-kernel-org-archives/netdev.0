From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Mon, 13 Sep 2004 15:45:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003c01c499e3$6e910440$a010100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
>From the time we generated the patch to the latest kernel version(2.6.8.1),
there seems to be a one line change(see change below) in s2io.c(done by 
one of the community developers). So, our patch may not apply cleanly. 
If you want us to regenerate the patch, we'll do it but the patch itself
is still valid. Following is the change done in the latest 2.6.8.1 kernel:

1428c1428
< 		skb = dev_alloc_skb(size + HEADER_ALIGN_LAYER_3);
---
> 		skb = dev_alloc_skb(size + NET_IP_ALIGN);
1434c1434
< 		skb_reserve(skb, HEADER_ALIGN_LAYER_3);
---
> 		skb_reserve(skb, NET_IP_ALIGN);

Thanks,
Ravi

-----Original Message-----
From: Ravinandan Arakali [mailto:ravinandan.arakali@s2io.com]
Sent: Monday, September 13, 2004 10:10 AM
To: 'Jeff Garzik'
Cc: 'netdev@oss.sgi.com'; 'leonid.grossman@s2io.com';
'raghavendra.koushik@s2io.com'; 'rapuru.sriram@s2io.com'
Subject: RE: Patch submission for S2io Xframe driver to 2.6 kernel


Hi Jeff,
Attached is the patch with the first round comments incorporated.
In addition, this patch contains
Some fixes related to 32-bit systems.
Few fixes related to Rx path in NAPI.

Thanks to all for the comments.

Pls review this patch as well and come back with your comments.

Regards,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Saturday, August 28, 2004 4:37 PM
To: ravinandan.arakali@s2io.com
Cc: netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel


is there a follow-up patch addressing the comments ?
