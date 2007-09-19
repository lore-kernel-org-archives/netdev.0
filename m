From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 19:06:04 +0100
Message-ID: <20070919190604.342363b4@the-village.bc.nu>
References: <46F13E8B.4050309@redhat.com>
	<p73sl5aveqh.fsf@bingen.suse.de>
	<46F15305.2030507@redhat.com>
	<20070919172653.GB18045@one.firstfloor.org>
	<46F1608E.7060908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756895AbXISR7m@vger.kernel.org>
In-Reply-To: <46F1608E.7060908@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 10:46:54 -0700
Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andi Kleen wrote:
> >> But the spec calls for a "null address" to be used and that's in my
> >> understanding something different from using AF_UNSPEC.
> > 
> > memset(&sockaddr, 0, sizeof(sockaddr)) should give you AF_UNSPEC
> 
> But the spec calls for <quote>null address for the protocol</quote>.
> 
> That means the family for the null address is the same as the family of
> the socket.

Which is a valid address in some protocols. If I remember rightly then
appletalk net 0 node 0 port 0 is valid although I'd want to look in the
book to check that - ditto AF_ECONET although I doubt anyone cares too
much 8)

Alan
