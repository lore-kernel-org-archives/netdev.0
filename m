From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 10:22:06 +0200
Message-ID: <b3f268590608230122k60e3c7c7y939d5559d97107f@mail.gmail.com>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com>
	 <20060822231129.GA18296@ms2.inr.ac.ru>
	 <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com>
	 <20060822.173200.126578369.davem@davemloft.net>
	 <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
	 <20060823065659.GC24787@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.207]:10686 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932432AbWHWIWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 04:22:07 -0400
Received: by nz-out-0102.google.com with SMTP id n1so29260nzf
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 01:22:06 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060823065659.GC24787@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> void * in structure exported to userspace is forbidden.

Only void * I'm seeing belongs to the user, (udata) perhaps you are
talking of something different?

> long in syscall requires wrapper in per-arch code (although that
> workaround _is_ there, it does not mean that broken interface should
> be used).
> poll uses millisecods - it is perfectly ok.

The kernel is there to hide those ugly implementation details from the
user, so I don't care that much about a workaround being required in
some cases. More important, IMHO is consistency with the POSIX system
calls.

I guess as long as you use usec, at least it won't be a pain to use.

Rakshasa
