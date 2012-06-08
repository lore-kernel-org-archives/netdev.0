From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 12:13:04 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1206081212150.1360-100000@iolanthe.rowland.org>
References: <CA+v9cxag9NV2ud+oupyziLN3nLgkgj+kyTcaOnEjYNjqXtM4Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxag9NV2ud+oupyziLN3nLgkgj+kyTcaOnEjYNjqXtM4Bw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Jun 2012, Huajun Li wrote:

> > One possibility is to wait for a little while before resubmitting the
> > URB, and after 10 failures in a row, attempt a reset.
> >
> Alan, thanks for your proposal.
> You mean reset the device after 10 failures, right ?

Yes.  But I don't know if it will help your problem.

> BTW, I ever tried to sleep several seconds before submitting the 1st
> interrupt URB, but it did not work.

As Ming Lei said, it sounds like your device isn't working right.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
