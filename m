From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Tue, 29 Apr 2008 19:36:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804291934470.18219@shark.he.net>
References: <87zlrgl09s.fsf@sparse.dyndns.org>  <1209435597.2624.35.camel@debian.sh.intel.com>
  <20080429132720.GB4887@tuxdriver.com> <1209521679.2827.23.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:41256 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754595AbYD3Cgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 22:36:43 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 19:36:35 -0700
In-Reply-To: <1209521679.2827.23.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Apr 2008, Zhu Yi wrote:

> On Tue, 2008-04-29 at 09:27 -0400, John W. Linville wrote:
> > 
> > > Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI
> > with
> > > the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)? AFAICS,
> > > CONFIG_IWLWIFI is always 'y' whenever CONFIG_IWLCORE is 'y' or 'm'.
> > If
> > > the latter is 'm', the Makefile will generate a empty built-in.o
> > which
> > > requires vmlinux to update unnecessarily every time we only compile
> > > iwl3945/4965 modules.
> > 
> > Can you do something like  "default IWLCORE'?  Untested, off the top
> > of my head...
> 
> I just realized the kernel now updates vmlinux when I type 'make' even
> if nothing is changed in the source code. Is this a bug or feature?

I see files in arch/x86/kernel/acpi/realmode/ always being built.
Is that what you see or is it something else?

You can do
  make V=2 all >build.log 2>&1
to see what is being rebuilt and hopefully why.
Then post that and maybe we can fix it (with the right people helping).

-- 
~Randy
