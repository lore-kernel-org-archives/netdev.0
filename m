From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH net 1/4] pegasus: Use heap buffers for all register
 access
Date: Mon, 6 Feb 2017 13:30:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027C7C7@AcuExch.aculab.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk> <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310> <20170206082822.GA23451@kroah.com>
 <20170206125108.d5vdur5rlvrkpr5j@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?Windows-1252?Q?Lisandro_Dami=E1n_Nicanor_P=E9rez_Meyer?=
        <lisandro-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
To: 'Petko Manolov' <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170206125108.d5vdur5rlvrkpr5j@localhost>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov
> Sent: 06 February 2017 12:51
...
> I suspect getting the buffer allocation in usb_control_msg() will help with two
> things in the same time:
> 
>  - allocate in DMA-able memory;
>  - code reduction;

Is there code around there to do 'bounce buffer' allocation
for systems where not all dma memory is actually accessible
by all devices??

In which case it could (probably) be used for non-dma memory?

	David

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
