From: "Hua Zhong" <hzhong@gmail.com>
Subject: RE: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Thu, 11 Nov 2010 13:58:02 -0800
Message-ID: <00c201cb81eb$84e18160$8ea48420$@com>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>
To: "'Eric Paris'" <eparis@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, I realize this is little different than if the
> SYN was dropped in the first network device, but it is different
> because we know what happened!  We know that connect() call failed
> and that there isn't anything coming back.

I would argue that -j DROP should behave exactly as the packet is dropped in the network, while -j REJECT should signal the failure to the application as soon as possible (which it doesn't seem to do).

It does not only make sense, but also is a highly useful testing technique that we use -j DROP in OUTPUT to emulate network losses and see how the application behaves.
