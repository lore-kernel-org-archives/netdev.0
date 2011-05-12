From: Johannes Sixt <j6t@kdbg.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up
 hard right after logging in)
Date: Thu, 12 May 2011 20:54:53 +0200
Message-ID: <4DCC2CFD.4010807@kdbg.org>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com> <BANLkTi=YDZa+BRaG90vJsjrT9VxgySrDRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Lutomirski <luto@mit.edu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, git@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <git-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=YDZa+BRaG90vJsjrT9VxgySrDRQ@mail.gmail.com>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 12.05.2011 19:37, schrieb Linus Torvalds:
> If you think it's networking, for example, and you've bisected into
> there but aren't sure, do "gitk --bisect", find the point where I
> merge, and pick that (and my parent), and "git bisect reset" those
> points.

Except that you should git reset --hard; git bisect reset gets you out
of bisect-mode, no?

-- Hannes
