From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/2] forcedeth: make module parameters readable in
 /sys/module
Date: Wed, 18 May 2011 23:09:18 -0400
Message-ID: <20110518230918.5c03ba68.billfink@mindspring.com>
References: <1305753000-14933-1-git-send-email-decot@google.com>
	<20110518150346.508d6406@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <decot@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518150346.508d6406@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2011, Stephen Hemminger wrote:

> On Wed, 18 May 2011 14:09:59 -0700
> David Decotigny <decot@google.com> wrote:
> 
> > This change allows to publish the values of the module parameters in
> > /sys/module.
> 
> Although this makes more info for developer, it also means more
> stuff in sysfs taking more memory and not providing any real value
> that can't be found by looking at the /etc/modprobe.d for any parameters
> user might have set.

As a user, I find having the module parameter info in
/sys/module/driver/parameters/* extremely useful at times.
In tracking down weird problems I can for example do:

	grep . /sys/module/driver/parameters/*

to get a snapshot of module parameters.  I can then compare
this with other similar systems to see if there are any
differences of note that might be significant (anything
from differences due to kernel versions to just forgetting
some change I made).

I don't see that it's really much extra significant overhead
on the system either.

					-Bill
