From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Sat, 11 Aug 2007 09:47:51 +0100
Message-ID: <7680.1186822071@redhat.com>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758974AbXHKIs6@vger.kernel.org>
In-Reply-To: <46BCC26B.6080600@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> wrote:

> cpu_relax() contains a barrier, so it should do the right thing.  For non-smp
> architectures, I'm concerned about interacting with interrupt handlers.  Some
> drivers do use atomic_* operations.

I'm not sure that actually answers my question.  Why not smp_rmb()?

David
