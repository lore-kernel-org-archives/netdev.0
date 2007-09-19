From: Andi Kleen <andi@firstfloor.org>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 19:57:00 +0200
Message-ID: <20070919175700.GC18045@one.firstfloor.org>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org> <46F1608E.7060908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763850AbXISR5X@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46F1608E.7060908@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 10:46:54AM -0700, Ulrich Drepper wrote:
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

Spec doesn't match traditional behaviour then. IPv4 0.0.0.0 is 
traditionally an synonym for old style all broadcast (255.255.255.255) 
on UDP/RAW and it's certainly possible to connect() to that. 

-Andi
