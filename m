From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] net: usb: allow MTU that is a multiple of USB packet
 size
Date: Thu, 07 May 2015 13:07:37 +0200
Message-ID: <1430996857.30151.8.camel@suse.de>
References: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
	 <1430993477.30151.6.camel@suse.de>
	 <CAB=otbTxAit3d8ns5PaOK_QF8oEzMbSjTuY3e+cqwrmZs8WVSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ruslan Bilovol <ruslan.bilovol@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=otbTxAit3d8ns5PaOK_QF8oEzMbSjTuY3e+cqwrmZs8WVSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-07 at 13:51 +0300, Ruslan Bilovol wrote:
> Hi Oliver,
> 
> On Thu, May 7, 2015 at 1:11 PM, Oliver Neukum <oneukum@suse.de> wrote:
> > On Thu, 2015-05-07 at 12:49 +0300, Ruslan Bilovol wrote:
> >> Current usbnet driver rejects setting MTU that is a multiple
> >> of USB endpoint's wMaxPacketSize size. However, it may only
> >> lead to possible performance degradation but is not so
> >> critical that its using should be prohibited. So allow it
> >> but also warn user about possible issue.
> >
> > We have reports about devices reacting badly to ZLPs.
> > Unless you have a compelling reasons for this change
> > I have to reject it.
> 
> What devices do you mean here: USB network adapters or USB host controllers?

The network adapters

> If it's just network adapters, then we can create some kind of quirk handling
> for them and do not disable this functionality just because some buggy device
> can't work with it.

No. They are too many.

> My device works fine with ZLPs so I want to use this particular MTU under Linux
> like I do it under other operation systems.

We can have a white list, but the general case is just too dangerous.

	Sorry
		Oliver
