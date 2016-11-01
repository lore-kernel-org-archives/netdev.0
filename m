From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Tue, 1 Nov 2016 17:27:56 +0100
Message-ID: <7f83a405-0520-a3ed-fc21-402d702483f9@stressinduktion.org>
References: <20161031.151534.329043104568805244.davem@davemloft.net>
 <87bmxznsgg.fsf@redhat.com>
 <20161101.113505.1429989348222226550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, jkbs@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101.113505.1429989348222226550.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.11.2016 16:35, David Miller wrote:
> I have a really hard time accepting a "fix" that depends upon behavior
> that the Linux ipv6 stack doesn't even have.

We actually support this feature:

commit df3687ffc6653e4d32168338b4dee20c164ed7c9
Author: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date:   Fri Jan 17 17:15:03 2014 +0100

    ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET

Add that time I tried to stick to the common practices at that time and
was against any kind of global sysctl enabling a reflection mode for
flowlabels. State of art was to keep some uniqueness in flowlabels, thus
also the introduction of the flowlabel_consistency label.

We basically can support reflection nowadays globally pretty easy, as we
have soften these rules a lot.

Bye,
Hannes
