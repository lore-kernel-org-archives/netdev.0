From: Mauro Carvalho Chehab <mchehab@infradead.org>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 19:16:39 -0200
Message-ID: <20091120191639.263714e2@pedra>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755698AbZKTVQi@vger.kernel.org>
In-Reply-To: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Luis,

Em Fri, 20 Nov 2009 12:45:51 -0800
"Luis R. Rodriguez" <mcgrof@gmail.com> escreveu:

> Everyone and their mother reinvents the wheel when it comes to
> backporting kernel modules. It a painful job and it seems to me an
> alternative is possible. If we can write generic compatibilty code for
> a new routine introduced on the next kernel how about just merging it
> to the kernel under some generic compat module. This would be
> completey ignored by everyone using the stable kernel but can be
> copied by anyone doing backport work.
> 
> So I'm thinking something as simple as a generic compat/comat.ko with
> compat-2.6.32.[ch] files.
> 
> We've already backported everything needed for wireless drivers under
> compat-wireless under this format down to even 2.6.25. I volunteer to
> be the sucker for this if this is reasonable and given the shot to try
> it.
> 

We have several backport stuff at our development tree, that works for
V4L/DVB up to kernel 2.6.16 (so, up to RHEL5).

It is based on a compat.h file, plus some extra tests inside the drivers.
They are at:
	http://linuxtv.org/hg/v4l-dvb

I also started working on a different approach of dynamically patching the
drivers based on some semantic rules, parsed in perl, but I hadn't enough
time to finish.

If you want to take a look, it is at:

	http://linuxtv.org/hg/~mchehab/backport/


Cheers,
Mauro
