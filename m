From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 2 Aug 2005 16:13:57 -0700
Message-ID: <000901c597b7$dc316080$4810100a@pc.s2io.com>
References: <20050731140515.GA6261@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
        <raghavendra.koushik@neterion.com>, <jgarzik@pobox.com>,
        <netdev@oss.sgi.com>, <leonid.grossman@neterion.com>,
        <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
In-Reply-To: <20050731140515.GA6261@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Christoph,
Following is SGI's stand on this issue:

SGI recommends that customers use the -sn2 kernel. This is the kernel 
that is installed by our factory when we ship systems. The -sn2 
kernel is also the kernel that must be run if the Altix has more that 
128 CPUs. So I'd be surprised it the majority of the Altix systems in 
the field are not running the -sn2 kernel.

Thanks,
Ravi

-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org]
Sent: Sunday, July 31, 2005 7:05 AM
To: Ravinandan Arakali
Cc: 'David S. Miller'; hch@infradead.org;
raghavendra.koushik@neterion.com; jgarzik@pobox.com; netdev@oss.sgi.com;
leonid.grossman@neterion.com; rapuru.sriram@neterion.com
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements


On Fri, Jul 29, 2005 at 09:37:55AM -0700, Ravinandan Arakali wrote:
> David,
> We are trying to use the "default" directive in Kconfig. We tried
> using an unconditional directive(just to test it out) such as
> "default y" and a conditional one such as "default y if
> CONFIG_IA64_SGI_SN2".

Again, please make this a module option, CONFIG_IA64_SGI_SN2 does not
mean runs on Altix but that this is a kernel that only supports Altix,
which is a non-standard case that doesn't cover 90% or more of actual
Altix systems in the field and running 2.6.
