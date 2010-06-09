From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 09 Jun 2010 16:00:51 +0300
Message-ID: <1276088452.31892.50.camel@chilepepper>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, 2010-06-03 at 21:14 +0200, Coelho Luciano (Nokia-D/Helsinki)
wrote:
> From: Luciano Coelho <luciano.coelho@nokia.com>
> 
> This patch implements an idletimer Xtables target that can be used to
> identify when interfaces have been idle for a certain period of time.
> 
> Timers are identified by labels and are created when a rule is set with a new
> label.  The rules also take a timeout value (in seconds) as an option.  If
> more than one rule uses the same timer label, the timer will be restarted
> whenever any of the rules get a hit.
> 
> One entry for each timer is created in sysfs.  This attribute contains the
> timer remaining for the timer to expire.  The attributes are located under
> the xt_idletimer class:
> 
> /sys/class/xt_idletimer/timers/<label>
> 
> When the timer expires, the target module sends a sysfs notification to the
> userspace, which can then decide what to do (eg. disconnect to save power).
> 
> Cc: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
> ---
> v2: Fixed according to Jan's comments
> v3: Changed to a device class in the virtual bus in sysfs
>     Removed unnecessary attribute group
>     Fixed missing deallocation in some error cases

Does this patch look fine now or is there something more I need to do to
get it applied?

If it's okay already, are you waiting for the merge window to close
before applying it?

Sorry to bother you with this, but we're depending on this feature and I
need to know if there's something more to be doen.

I'll provide the extension for the iptables tool pretty soon.


-- 
Cheers,
Luca.

