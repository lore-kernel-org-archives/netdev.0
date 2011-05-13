From: Johannes Sixt <j6t@kdbg.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up
 hard right after logging in)
Date: Fri, 13 May 2011 20:34:08 +0200
Message-ID: <4DCD79A0.7000500@kdbg.org>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com> <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com> <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com> <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com> <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Lutomirski <luto@mit.edu>,
	Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 13.05.2011 19:54, schrieb Linus Torvalds:
> For example, in your case, since you had certain requirements of
> support that simply didn't exist earlier, something like
> 
>    git bisect requires v2.6.38
> 
> would have been really useful - telling git bisect that any commit
> that cannot reach that required commit is not even worth testing.

You can already have this with

   git bisect good v2.6.38

It sounds a bit unintuitive, but with a slight mind-twist it can even be
regarded as correct in a mathematical sense: when the precondition is
false, the result is true. ;-)

-- Hannes
