From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Is ndo_do_ioctl still acceptable?
Date: Thu, 12 Nov 2015 17:58:56 +0100
Message-ID: <CAHmME9p31NYxhUeiK=S-6XmKxEBigUyiqEz3SJJrA1zNXaaXLA@mail.gmail.com>
References: <CAHmME9puHv8uaUKX4AOjEaTNN6bHqNKqvaCqubc5erk+jnDOEw@mail.gmail.com>
	<20151112083443.48785696@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151112083443.48785696@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Thanks for your response.

On Thu, Nov 12, 2015 at 5:34 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> The problem is ioctl's are device specific, and therefore create dependency
> on the unique features supported by your device.
> The question always comes up, why is this new API not something general?

In this case, it really is for unique features of my device. My device
has its own unique notion of a "peer" based on a particular elliptic
curve point and some other interesting things. It's not something
generalizable to other devices. The thing that makes my particular
device special is these attributes that I need to make configurable. I
think then, by your criteria, ioctl would actually be perfect. In
other words, I interpret what you wrote to mean "generalizable:
netlink. device-specific: ioctl." If that's a decent summary, then
ioctl is certainly good for me.

> And if you are dumping such a huge mound of information that only your driver
> could love, then why are you doing it? Is there anything in there that
> really matters?

There is. There's a nice userspace program used for configuring and
displaying the particular attributes of this device.

> If all you are really doing is dumping statistics then look at ethtool.

It's more than stats, unfortunately.

> If you are dealing with lots of virtual function devices, look how existing
> netlink info is trimmed.

Could you elaborate on this? What do you mean "trimmed"? And where do I look?

Regards,
Jason
