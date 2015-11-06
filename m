From: Tom Herbert <tom@herbertland.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Fri, 6 Nov 2015 16:19:20 +0900
Message-ID: <CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 5, 2015 at 7:52 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hi folks,
>
> When sending arbitrary SKBs with udp_tunnel_xmit_skb, the networking
> stack does not appear to be utilizing UFO on the outgoing UDP packets,
> which significantly caps the transmission speed. I see about 50% CPU
> usage in this send path, triggered for every single outgoing packet.
> Is there a particular skb option I need to set to enable this? I read
> Tom's patch [1] from last year, but this seems to be about setting the
> inner packet type. In my case, the inner type is opaque encrypted
> data, so there's not a relevant setting.
>
Jason,

Is this about UFO or GSO (in email subject)? UFO should operate
independently encapsulation or inner packet setting.

Tom

> Thanks,
> Jason
>
> [1] http://thread.gmane.org/gmane.linux.network/332194
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
