From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 19 Nov 2013 22:09:52 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
References: <20131119225822.GA9611@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131119225822.GA9611@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Nov 2013, Sarah Sharp wrote:

> The xHCI driver can limit the number of sg-list entries through
> hcd->self.sg_tablesize.  It's currently set to ~0, which is "however
> many entries you want.  You could set that to the number of TRBs in a
> segment (minus one for the link TRB).
> 
> The usb-storage and uas drivers currently use sg_tablesize.  Could the
> network stack be taught to use sg_tablesize as well?

The sg_tablesize you're talking about is a field in struct usb_bus
(there's a similar field in struct scsi_host_template).  It's not
relevant to the network stack, since network interfaces aren't USB host
controllers (or SCSI hosts).

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
