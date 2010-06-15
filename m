From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v6] netfilter: Xtables: idletimer target implementation
Date: Tue, 15 Jun 2010 16:18:54 +0300
Message-ID: <1276607934.1580.58.camel@powerslave>
References: <1276605926-11598-1-git-send-email-luciano.coelho@nokia.com>
	 <4C177A89.7060301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	Timo Teras <timo.teras@iki.fi>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C177A89.7060301@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-06-15 at 15:05 +0200, ext Patrick McHardy wrote:
> Luciano Coelho wrote:
> > This patch implements an idletimer Xtables target that can be used to
> > identify when interfaces have been idle for a certain period of time.
> >
> > Timers are identified by labels and are created when a rule is set with a new
> > label.  The rules also take a timeout value (in seconds) as an option.  If
> > more than one rule uses the same timer label, the timer will be restarted
> > whenever any of the rules get a hit.
> >
> > One entry for each timer is created in sysfs.  This attribute contains the
> > timer remaining for the timer to expire.  The attributes are located under
> > the xt_idletimer class:
> >
> > /sys/class/xt_idletimer/timers/<label>
> >
> > When the timer expires, the target module sends a sysfs notification to the
> > userspace, which can then decide what to do (eg. disconnect to save power).
> >   
> 
> Applied with a minor compiler warning fix:
> 
>   CC [M]  net/netfilter/xt_IDLETIMER.o
> net/netfilter/xt_IDLETIMER.c:255: warning: initialization from 
> incompatible pointer type
> 
> The struct xt_tgchk_param argument to ->checkentry is const.

Oops, missed that one.  Thanks for fixing it.

And thanks a lot for bearing with a netfilter newbie, providing lots of
good comments and generally helping me with this component! I really
appreciate it.

-- 
Cheers,
Luca.

