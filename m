From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 8 Feb 2017 01:09:41 +0000
Message-ID: <1486516168.2581.21.camel@sandisk.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
         <1486502926.2581.4.camel@sandisk.com>
         <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
         <1486504716.2581.8.camel@sandisk.com>
         <20170208005416.GA76793@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org"
        <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170208005416.GA76793-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Content-Language: en-US
Content-ID: <D37C559519745445B5AF39718D476279-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-07 at 16:54 -0800, Vishwanathapura, Niranjana wrote:
> On Tue, Feb 07, 2017 at 09:58:50PM +0000, Bart Van Assche wrote:
> > On Tue, 2017-02-07 at 21:44 +0000, Hefty, Sean wrote:
> > > This is Ethernet - not IP - encapsulation over a non-InfiniBand device/protocol.
> > 
> > That's more than clear from the cover letter. In my opinion the cover letter
> > should explain why it is considered useful to have such a driver upstream
> > and what the use cases are of encapsulating Ethernet frames inside RDMA
> > packets.
> 
> We believe on our HW, HFI VNIC design gives better hardware resource usage 
> which is also scalable and hence room for better performance.
> Also as evident in the cover letter, it gives us better manageability by 
> defining virtual Ethernet switches overlaid on the fabric and
> use standard Ethernet support provided by Linux.

That kind of language is appropriate for a marketing brochure but not for a
technical forum. Even reading your statement twice did not make me any wiser.
You mentioned "better hardware resource usage". Compared to what? Is that
perhaps compared to IPoIB? Since Ethernet frames have an extra header and are
larger than IPoIB frames, how can larger frames result in better hardware
resource usage? And what is a virtual Ethernet switch? Is this perhaps packet
forwarding by software? If so, why are virtual Ethernet switches needed since
the Linux networking stack already supports packet forwarding?

Thanks,

Bart.--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
