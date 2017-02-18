From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [RFC v2 00/20] Replace PCI pool by DMA pool API
Date: Sat, 18 Feb 2017 18:57:36 +0100
Message-ID: <d5e67b7f-a22e-f737-e8c0-67e0599725d2@collabora.com>
References: <20170218083556.20215-1-romain.perier@collabora.com>
 <20170218130600.GA24938@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170218130600.GA24938-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Le 18/02/2017 à 14:06, Greg Kroah-Hartman a écrit :
> On Sat, Feb 18, 2017 at 09:35:36AM +0100, Romain Perier wrote:
>> The current PCI pool API are simple macro functions direct expanded to
>> the appropriated dma pool functions. The prototypes are almost the same
>> and semantically, they are very similar. I propose to use the DMA pool
>> API directly and get rid of the old API.
>>
>> This set of patches, replaces the old API by the dma pool API, adds
>> support to warn about this old API in checkpath.pl and remove the
>> defines.
> Why is this a "RFC" series?  Personally, I never apply those as it
> implies that the author doesn't think they are ready to be merged :)
>
> thanks,
>
> greg k-h
Hi,

I was not sure about this. I have noticed that most of the API changes
are tagged as RFC.
I can re-send a v3 without the prefix RFC if you prefer.

Thanks,
Romain
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
