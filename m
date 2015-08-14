From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: GCOV_PROFILE_ALL breaks BUILD_BUG_ON(!is_power_of_2(8))
Date: Fri, 14 Aug 2015 11:05:47 +0200
Message-ID: <1439543147.2091.11.camel@sipsolutions.net>
References: <1439457109-21833-1-git-send-email-johannes@sipsolutions.net>
	 <1439540944.2091.10.camel@sipsolutions.net>
	 <20150814090044.GB21759@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150814090044.GB21759@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-14 at 11:00 +0200, Michal Kubecek wrote:

> > but should I have expected this?
> 
> It might have something to do with the fact that is_power_of_2() 
> being an inline function, perhaps with this compiler option it 
> translates to something that can't be used in the context 
> BUILD_BUG_ON() uses it in.

Evidently, yeah.

> There is a BUILD_BUG_ON_NOT_POWER_OF_2() macro you could use.
> 

Good point, I'll do that, thanks.

johannes
