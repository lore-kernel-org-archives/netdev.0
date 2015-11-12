From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Is ndo_do_ioctl still acceptable?
Date: Thu, 12 Nov 2015 23:19:06 +0100
Message-ID: <CAHmME9pHg7iAorj22DvWKhrH4HXPne7ZBAr7X1wyR7VEkJfk8w@mail.gmail.com>
References: <CAHmME9puHv8uaUKX4AOjEaTNN6bHqNKqvaCqubc5erk+jnDOEw@mail.gmail.com>
	<20151112083443.48785696@xeon-e3>
	<CAHmME9p31NYxhUeiK=S-6XmKxEBigUyiqEz3SJJrA1zNXaaXLA@mail.gmail.com>
	<5644F6E7.4060901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5644F6E7.4060901@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 9:30 PM, Austin S Hemmelgarn
<ahferroin7@gmail.com> wrote:
>>
> On the other hand, based on what you are saying about your device, it sounds
> like you are working on some kind of cryptographically secured (either
> authenticated or encrypted or both) tunnel, in which case the fact that
> security is easier to handle with netlink than ioctls becomes important.  If
> you can't ensure security of the endpoint configuration, you can't ensure
> security of the tunnel itself.

Could you substantiate these claims that "security is easier to handle
with netlink". I've never heard this and I don't know why it'd be the
case. Are you referring to the fact that the copy_to/from_user dance
of ioctl opens up more potential vulnerabilities than netlink's
abstracted validation? Or something else? Just confused here...
