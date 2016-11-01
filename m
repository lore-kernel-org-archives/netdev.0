From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Tue, 1 Nov 2016 17:25:07 +0100
Message-ID: <af3e302e-4fd0-e63c-4520-63a6e2341c22@stressinduktion.org>
References: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
 <8760oa9egg.fsf@redhat.com>
 <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>, Jakub Sitnicki <jkbs@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.10.2016 20:25, Tom Herbert wrote:
> The normal hash for TCP or UDP using ECMP is over <protocol, srcIP,
> dstIP, srcPort, dstPort>. For an ICMP packet ECMP would most likely be
> done over <protocol, srcIP, dstIP>. There really is no way to ensure
> that an ICMP packet will follow the same path as TCP or any other
> protocol. Fortunately, this is really isn't so terrible. The Internet
> has worked this way ever since routers started using ports as input to
> ECMP and that hasn't caused any major meltdown.

The normal hash for forwarding is without srcPort or dstPort, so the
same as ICMP and especially also because of fragmentation problematic I
don't think a lot of routers use L4 port information for ECMP either.

Bye,
Hannes
