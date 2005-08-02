From: "'Christoph Hellwig'" <hch@infradead.org>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Wed, 3 Aug 2005 00:26:45 +0100
Message-ID: <20050802232645.GA20313@infradead.org>
References: <20050731140515.GA6261@infradead.org> <000901c597b7$dc316080$4810100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        "'David S. Miller'" <davem@davemloft.net>,
        raghavendra.koushik@neterion.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Content-Disposition: inline
In-Reply-To: <000901c597b7$dc316080$4810100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 02, 2005 at 04:13:57PM -0700, Ravinandan Arakali wrote:
> Hi Christoph,
> Following is SGI's stand on this issue:
> 
> SGI recommends that customers use the -sn2 kernel. This is the kernel 
> that is installed by our factory when we ship systems. The -sn2 
> kernel is also the kernel that must be run if the Altix has more that 
> 128 CPUs. So I'd be surprised it the majority of the Altix systems in 
> the field are not running the -sn2 kernel.

The my argument is wrong for SuSE ;-)  This still needs to be a runtime
switch though, not just for this reason.  Platform ifdefs are not the
way to go.
