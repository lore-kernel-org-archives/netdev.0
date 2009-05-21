From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d" as
	interface name
Date: Thu, 21 May 2009 18:43:01 +0200
Message-ID: <ac3eb2510905210943h109e6cc6o76e9978fe47a6eac@mail.gmail.com>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de> <20090521134856.GA3457@psychotron.englab.brq.redhat.com>
	<4A1565B6.10907@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Fenlason <fenlason@redhat.com>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <4A1565B6.10907@s5r6.in-berlin.de>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 21, 2009 at 16:31, Stefan Richter <stefanr@s5r6.in-berlin.d=
e> wrote:
> Usually I prefer brevity too. =C2=A0Alas, it may not be clear to many=
 people what
> "fw" is supposed to mean. =C2=A0People might associate it with, let's=
 say,
> "firewall" before "firewire" when they deal with networking. However,=
 more
>  opinions on this are welcome.

Yeah, common one is also "firmware". I think "firewire" is fine.

> As for practical length restrictions: =C2=A0The kernel's networking c=
ore requires
> that these names fit into 15 characters plus trailing \0. =C2=A0I don=
't have an
> idea whether there are userland components which have even tighter
> restrictions.
>
> Does anybody know of potential trouble in networking tools if interfa=
ce
> names are 9 or 10 characters long?

I don't think so, stuff at the tools level usually works flawlessly
with "eth0_rename_ren" devices, when things went wrong with renaming
the devices. :)

Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
