From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] proc connector: reject unprivileged listener bumps
Date: Tue, 26 Feb 2013 12:46:06 +0400
Message-ID: <20130226084606.GA21048@ioremap.net>
References: <20130226073225.GA15489@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Matt Helsley <matthltc@us.ibm.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130226073225.GA15489@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Mon, Feb 25, 2013 at 11:32:25PM -0800, Kees Cook (keescook@chromium.org) wrote:
> While PROC_CN_MCAST_LISTEN/IGNORE is entirely advisory, it was possible
> for an unprivileged user to turn off notifications for all listeners by
> sending PROC_CN_MCAST_IGNORE. Instead, require the same privileges as
> required for a multicast bind.

Sounds resonable.
Not sure whether this is a candidate for stable release, but otherwise
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
