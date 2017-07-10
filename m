From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH 1/2] netdevice: add netdev_pub helper function
Date: Mon, 10 Jul 2017 13:52:45 +0200
Message-ID: <CAHmME9rMQdukz-Nw_9uDqLYg5od5QFHK8K_boC0gRkvxz0jjqw@mail.gmail.com>
References: <20150612.142058.1085284048217032168.davem@davemloft.net>
 <20170710031959.7496-1-Jason@zx2c4.com> <20170710.090407.1592129544725682024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710.090407.1592129544725682024.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2017 at 10:04 AM, David Miller <davem@davemloft.net> wrote:
> I disagree.  Assuming one can go from the driver private to the netdev
> object trivially is a worse assumption than the other way around, and
> locks us into the current implementation of how the netdev and driver
> private memory is allocated.
>
> If you want to style your driver such that the private is passed
> around instead of the netdev, put a pointer back to the netdev object
> in your private data structure.

I'm surprised you're okay with the memory waste of that, but you bring
up the ability to change the interface later, which is a great point.
I'll submit a patch for that random driver, and I'll also refactor
WireGuard to do the same. Thanks for the guidance.

Jason
