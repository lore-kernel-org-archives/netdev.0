From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 08:44:29 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280444.IAA02959@sex.inr.ac.ru>
References: <20020928.133019.38287529.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.133019.38287529.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 28, 2 01:30:19 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> we need per socket preference.

What kind of? Some matching rules loaded to socket by user?

Anyway, rules established by a particular client should be separate,
it is just a generalization of bind()/IP{V6}_PKTINFO.

I am not sure that it is really interesting though. Just now I cannot
imagine what user can invent which is not covered by system-wide rules,
bind() and IP{V6}_PKTINFO. Well, if you think more hairy scheme is interesting,
feel free to implement this.

Alexey
