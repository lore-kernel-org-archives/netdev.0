From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: GSO with udp_tunnel_xmit_skb
Date: Thu, 5 Nov 2015 11:52:06 +0100
Message-ID: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: jbenc@redhat.com, therbert@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

When sending arbitrary SKBs with udp_tunnel_xmit_skb, the networking
stack does not appear to be utilizing UFO on the outgoing UDP packets,
which significantly caps the transmission speed. I see about 50% CPU
usage in this send path, triggered for every single outgoing packet.
Is there a particular skb option I need to set to enable this? I read
Tom's patch [1] from last year, but this seems to be about setting the
inner packet type. In my case, the inner type is opaque encrypted
data, so there's not a relevant setting.

Thanks,
Jason

[1] http://thread.gmane.org/gmane.linux.network/332194
