From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mac80211_hwsim: release driver when
 ieee80211_register_hw fails
Date: Wed, 29 Oct 2014 22:14:08 +0800
Message-ID: <20141029141408.GA9436@wfg-t540p.sh.intel.com>
References: <1414459907-7509-1-git-send-email-eternal.n08@gmail.com>
 <20141029064501.GB2985@piware.de>
 <8638a718ft.fsf@MJJ-LAPTOP.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Pitt <martin.pitt@ubuntu.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Junjie Mao <eternal.n08@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8638a718ft.fsf@MJJ-LAPTOP.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 06:23:02PM +0800, Junjie Mao wrote:
> I was not familiar with the acquiring/releasing API either, until I met
> with this bug...
> 
> Perhaps we can use static checkers to avoid these issues as early as
> possible. Any suggestions?

CC Dan. His smatch checker might be able (or could be enabled) to
handle the verification of missing device_release_driver() call.

Thanks,
Fengguang

> Martin Pitt <martin.pitt@ubuntu.com> writes:
> 
> > Acked-By: Martin Pitt <martin.pitt@ubuntu.com>
> >
> > Hello Junjie,
> >
> > Junjie Mao [2014-10-28  9:31 +0800]:
> >> The driver is not released when ieee80211_register_hw fails in
> >> mac80211_hwsim_create_radio, leading to the access to the unregistered (and
> >> possibly freed) device in platform_driver_unregister:
> >
> > Many thanks for fixing this! Sorry about that, I don't know these bits
> > very well.
> >
> > Martin
