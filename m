From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.5.73
Date: Mon, 21 Jul 2003 04:49:55 +0400 (MSD)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200307210049.EAA31237@dub.inr.ac.ru>
References: <20030719.093316.45294671.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org (YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20030719.093316.45294671.yoshfuji@linux-ipv6.org> from "YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Jul 19, 2003 09:33:16 AM
List-Id: netdev.vger.kernel.org

Hello!

> First part (prefixlist) seems ok to me.

The same is here. It looks good.


> Second part does not.

I do not like the latest version a lot. :-) Actually, previous one was
quite acceptable, but I think Yoshfuji's suggestion is so good that
it makes lots of sense to complete it. I could make this in IPv4 part,
actually, I started to make it as demo for Krishna, but two questions
remained unaswered:

1. How to allocate new attributes? It is bad just to add them to existing
IFLA_* ones or override them. I would suggest to create new attribute
IFLA_PROTINFO and to embed new protocol dependant attributes as 
subattributes a la RTA_METRICS. Another suggestions?

2. IFLA_INET6_CONF (and IFLA_INET_CONF). How to encode the values?
Array of int's is simple, compact and looks good. But I have some problem
with it. What if one day we want to implement changing the values?
It will be nasty. To forget about such perspective? Or to leave it to use
for "atomic" load of all the parameters?

Alexey
