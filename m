From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] forcedeth: make module parameters readable in
 /sys/module
Date: Wed, 18 May 2011 15:03:46 -0700
Message-ID: <20110518150346.508d6406@nehalam>
References: <1305753000-14933-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305753000-14933-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2011 14:09:59 -0700
David Decotigny <decot@google.com> wrote:

> This change allows to publish the values of the module parameters in
> /sys/module.
> 
>

Although this makes more info for developer, it also means more
stuff in sysfs taking more memory and not providing any real value
that can't be found by looking at the /etc/modprobe.d for any parameters
user might have set.
