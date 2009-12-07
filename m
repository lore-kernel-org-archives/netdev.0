From: reinette chatre <reinette.chatre@intel.com>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Mon, 07 Dec 2009 14:04:03 -0800
Message-ID: <1260223443.4653.794.camel@rc-desk>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au>
	 <20091207114158.GA2428@merkur.ravnborg.org> <4B1CF39A.5050806@suse.cz>
	 <20091207160903.GB18939@tuxdriver.com> <1260209537.4653.778.camel@rc-desk>
	 <4B1D76B1.6070601@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4B1D76B1.6070601@suse.cz>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-12-07 at 13:42 -0800, Michal Marek wrote:
> It seems there is some misunderstanding.
> The original problem reported by Stephen was that linux/utsrelease.h was
> moved to generated/utsrelease.h in the kbuild tree (that commit also
> patched init/version.c and all other users known at that time). This
> change in kbuild broke the new iwlwifi in the net tree. Stephen attached
> the most obvious fix, i.e. change linux/utsrelease.h to
> generated/utsrelease.h in the iwlwifi source
> (http://lkml.org/lkml/2009/12/7/121). My suggestion was to let Stephen
> carry the fix in linux-next for now, and once one of the trees (kbuild
> or net) hits mainline, the other tree would apply Stephen's patch. Would
> that work for everyone?

I am not involved in the merging part and would thus not be the one
applying Stephen's patch. I would like the iwlwifi patch that uses
UTS_RELEASE as well as Stephen's fix to find it in the right place to go
in though (end up in linux-2.6).

> Now if someone wants to remove the DRV_VERSION macro from iwlwifi or rip
> the UTS_RELEASE part out of it, that would make this problem go away,
> but I don't think it's necessary _just_ because of the kbuild change.

This is perhaps something John and I should discuss separately.

Thank you

Reinette
