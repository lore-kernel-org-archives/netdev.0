From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.32.8-stable review : kernel crashed asap
Date: Fri, 5 Feb 2010 23:57:01 +0800
Message-ID: <20100205155701.GC9690@hack>
References: <201002042129.41462.toralf.foerster@gmx.de> <20100205151021.GB9690@hack> <201002051622.02980.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201002051622.02980.toralf.foerster@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 05, 2010 at 04:22:02PM +0100, Toralf F=C3=B6rster wrote:
>
>Am=C3=A9rico Wang wrote at 16:10:21
>> On Thu, Feb 04, 2010 at 09:29:41PM +0100, Toralf F=C3=B6rster wrote:
>> >Immediately during boot it crashed w/ the attached config - no line=
s
>> > within syslog  to post.
>>=20
>> What error messages did you see on your screen?
>>=20
>
>I attached a screen shot.
>

Thanks! It's better that if you can capture these info via netconsole
or something like that, so that you copy and paste them into email.

Hmm, it seems that a null pointer deref happened in
net/ipv4/devinet.c::inetdev_init(), so Cc'ing netdev guys....

Could you please run the command:

  addr2line -e your_2.6.32.8_vmlinux 0xc11fea28

to check in which line we dereferenced a null pointer?

Thank you!

--=20
Live like a child, think like the god.
=20
