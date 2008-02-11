From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] [RESENDING] netconsole: register cmdline netconsole
	configs to configfs
Date: Mon, 11 Feb 2008 10:30:13 -0600
Message-ID: <1202747413.28085.1.camel@cinder.waste.org>
References: <12027209122955-git-send-email-joonwpark81@gmail.com>
	 <12027209163465-git-send-email-joonwpark81@gmail.com>
	 <12027209202884-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, satyam@infradead.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758384AbYBKQbQ@vger.kernel.org>
In-Reply-To: <12027209202884-git-send-email-joonwpark81@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2008-02-11 at 18:08 +0900, Joonwoo Park wrote:
> This patch intorduces cmdline netconsole configs to register to
> configfs
> with dynamic netconsole. Satyam Sharma who designed shiny dynamic
> reconfiguration for netconsole, mentioned about this issue already.
> (http://lkml.org/lkml/2007/7/29/360)
> But I think, without separately managing of two kind of netconsole
> target
> objects, it's possible by using config_group instead of
> config_item in the netconsole_target and default_groups feature of
> configfs.
> 
> Patch was tested with configuration creation/destruction by kernel and
> module.
> And it makes possible to enable/disable, modify and review netconsole
> target configs from cmdline.

I'm afraid I'm going to have to leave review of this to someone who is
clueful about configfs. But it seems reasonable.

-- 
Mathematics is the supreme nostalgia of our time.
