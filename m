From: John Stultz <john.stultz@linaro.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Mon, 7 Aug 2017 14:15:32 -0700
Message-ID: <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 7, 2017 at 2:05 PM, John Stultz <john.stultz@linaro.org> wrote:
> So, with recent testing with my HiKey board, I've been noticing some
> quirky behavior with my USB eth adapter.
>
> Basically, pluging the usb eth adapter in and then removing it, when
> plugging it back in I often find that its not detected, and the system
> slowly spits out the following message over and over:
>   unregister_netdevice: waiting for eth0 to become free. Usage count = 1

The other bit is that after this starts printing, the board will no
longer reboot (it hangs continuing to occasionally print the above
message), and I have to manually reset the device.

thanks
-john
