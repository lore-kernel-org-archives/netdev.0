From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] ip6_output: ensure flow saddr actually belongs to device
Date: Sun, 13 Nov 2016 21:19:47 +0100
Message-ID: <CAHmME9rV_Qqj_QNKOARav6vOyyF-__E07saChPYo9MF6wED83A@mail.gmail.com>
References: <CAHmME9qYYU-p5BhR0ReNSB+__wysuDK+eEk1SisCoyf4=2woxg@mail.gmail.com>
 <20161113132347.17907-1-Jason@zx2c4.com> <405b2e79-854d-4c30-07b0-bd524137d2f6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <405b2e79-854d-4c30-07b0-bd524137d2f6@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sun, Nov 13, 2016 at 5:30 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> You can't require the address to be on the dst device. e.g., it can be an address from the loopback/vrf device.
>
> This block needs to be done at function entry, and pass dev as NULL to mean is the address assigned to any interface. That gets you the equivalency of the IPv4 check.

I gave v2 my best shot. Hopefully it's adequate, but I have a feeling
it might be best for you to just code up what you have in mind.

Regards,
Jason
