From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Fri, 14 Nov 2008 09:28:39 +1100
Message-ID: <18716.43543.256621.825529__34904.355396475$1226615427$gmane$org@cargo.ozlabs.ibm.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	<517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	<20081113140541.23754cad.akpm@linux-foundation.org>
	<18716.43376.534965.688695@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	"Michael Kerrisk" <mtk.manpages@gmail.com>,
	subrata@linux.vnet.ibm.com, linux-arch@vger.kernel.org,
	drepper@redhat.com, linux-kernel@vger.ke
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36160 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432AbYKMW2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 17:28:48 -0500
In-Reply-To: <18716.43376.534965.688695@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:

> Andrew Morton writes:
> 
> > > I think Ulrich wanted to try to see this patch in for 2.6.28; it's
> > > past the merge window of course, so it's up to you, but I have no
> > > problem with that.
> > 
> > That's easy - I'll send it to Linus and let him decide ;)
> 
> Ulrich's patch only updated x86.  If you're going to send it to Linus,
> please give us other architecture maintainers a chance to get patches
> to you to wire it up on our architectures, and then send Linus the
> combined patch.

Actually, any architecture that uses sys_socketcall should be OK
already, by the looks, and that includes powerpc.

Paul.
