From: Sergio Luis <eeeesti@gmail.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Tue, 14 Jul 2009 15:37:22 -0300
Message-ID: <ce0170d90907141137o6bcc9cc6iacbb82e5bbc28753@mail.gmail.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	 <20090404.170539.148727646.davem@davemloft.net>
	 <ce0170d90907141017h732c2cd7ja5990303093b6edd@mail.gmail.com>
	 <20090714.113348.155881037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amluto@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755893AbZGNShY@vger.kernel.org>
In-Reply-To: <20090714.113348.155881037.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2009 at 3:33 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: Sergio Luis <eeeesti@gmail.com>
> Date: Tue, 14 Jul 2009 14:17:21 -0300
>
>> is this patch incorrect, though? with the linkwatch_fire_event() cal=
l,
>> the rfc2863 operstate will be set for everyone at device register
>> time.
>
> The issue is dumb drivers that do not manage their link state
> at all. =A0We want them to always have their links up, from the
> moment they are registered.
>
> This is especially important for virtual devices.
>

I see. I will try to take a look at the driver in question, then. Thank=
s.
