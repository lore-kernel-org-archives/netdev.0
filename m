From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 21:11:06 +0100
Message-ID: <20080205201106.GB26150@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ross Vandegrift <ross@kallisti.us>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760387AbYBETg0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080205192559.GA10573@kallisti.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The problem is that any reasonably recent PC can generate enough
> forged SYN packets to overwhelm reasonable SYN queues on a much more
> powerful server.

Have you actually seen this with a recent kernel in the wild or are
you just talking theoretically?

Linux uses some heuristics to manage the syn queue that should
still ensure reasonable service even without cookies under attack.
Also SYN-RECV sockets are stored in a special data structure optimized
to use minimal resources.

It is far from the classical head drop method that was so vunerable
to syn flooding.

-Andi
