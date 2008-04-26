From: dean gaudet <dean@arctic.org>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Sat, 26 Apr 2008 15:41:28 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0804261540310.6108@twinlark.arctic.org>
References: <20080424160352.30f2dd5b@the-village.bc.nu>  <20080424154441.GG2255@devserv.devel.redhat.com>  <20080424162444.1c5b9ba2@the-village.bc.nu>  <20080424.090008.232544945.davem@davemloft.net>  <20080424163835.55520b5b@the-village.bc.nu>
 <517f3f820804240945l2dc203afx8fa432ac41219236@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>, jakub@redhat.com,
	drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760074AbYDZWli@vger.kernel.org>
In-Reply-To: <517f3f820804240945l2dc203afx8fa432ac41219236@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Apr 2008, Michael Kerrisk wrote:

> A while back I did some testing of this point.  These were the results I noted:
> 
> FreeBSD 4.8
> O_NONBLOCK and O_ASYNC are inherited
> FD_CLOEXEC is not inherited
> 
> Solaris 8
> O_NONBLOCK and O_ASYNC are inherited
> FD_CLOEXEC is not inherited
> 
> Tru64 5.1 (sep 03, testdrive)
> No F_SETFL flags are inherited
> FD_CLOEXEC is not inherited
> 
> HP-UX 11
> No F_SETFL flags are inherited
> FD_CLOEXEC is not inherited

invent FD_CLOEXEC_INHERITED to handle accept()?

-dean
