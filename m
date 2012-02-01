From: David Miller <davem@davemloft.net>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 31 Jan 2012 19:08:30 -0500 (EST)
Message-ID: <20120131.190830.1189531706541596294.davem@davemloft.net>
References: <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
	<20120131.115005.1292336126288944173.davem@davemloft.net>
	<CAGsizzLTHw5Ja3kT-zEN8uK5GrzpmN1bxOhA0OscGL5R6tH3WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLTHw5Ja3kT-zEN8uK5GrzpmN1bxOhA0OscGL5R6tH3WA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Wed, 1 Feb 2012 00:32:04 +0100

> About the new API. Openvswitch is using it's own GRE code, with it's
> own API. So if the finally NVGRE or VXLAN will be added to
> openvswitch,it doesn't breaks anything to leave also my API as is.

You don't understand.

If your code is superfluous in the end, we shouldn't add it in
the first place.

But if I do relent and let your code in now, we have to live
with it, and it's associated maintainence costs, FOREVER.

That's why I'm forcing this to be implemented properly from the start,
so we don't end up with two pieces of code that provide essentially
the same functionality.
