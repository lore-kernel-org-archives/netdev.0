From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 11 Apr 2008 16:05:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804111553450.28474@wrl-59.cs.helsinki.fi>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net>
 <20080403211913.3a0c1d00.akpm@linux-foundation.org> <200804041150.34046.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759963AbYDKNFt@vger.kernel.org>
In-Reply-To: <200804041150.34046.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Apr 2008, Rafael J. Wysocki wrote:

> On Friday, 4 of April 2008, Andrew Morton wrote:
> > 
> > (cc netdev)
> > 
> > (and Rafael - I assume 2.6.24 didn't do this..)
> > 
> > On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.org> wrote:
> 
> That's http://bugzilla.kernel.org/show_bug.cgi?id=10346 , I think. 
> 
> Robin, please add yourself to the CC list in the bugzilla entry above.
> 
> > > One of the nodes in my web-serving cluster (isohunt.com) started showing this:
> > > 
> > > ------------[ cut here ]------------
> > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()

Once Linus pulls net-2.6 fixes in, Robin's bug should be among the fixed 
ones (NewReno&TSO fix). ...Whereas the bugzilla's report might be due to 
another bug (it's different warn_on in any case).

-- 
 i.
