From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] net: ipv4 and ipv6: Convert
 printk(KERN_DEBUG to pr_debug
Date: Tue, 15 May 2012 18:49:47 -0700
Message-ID: <1337132987.7050.29.camel@joe2Laptop>
References: <cover.1337126962.git.joe@perches.com>
	 <1fd8285e798ec9b3817c790a67b2bb655ffc931b.1337126963.git.joe@perches.com>
	 <20120515183536.2cac1e29@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38243 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752128Ab2EPBtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 21:49:49 -0400
In-Reply-To: <20120515183536.2cac1e29@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 18:35 -0700, Stephen Hemminger wrote:
> On Tue, 15 May 2012 17:11:54 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > Use the current debugging style and enable dynamic_debug.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> This changes the action of the system. By default:
>   printk(KERN_DEBUG "foo\n");
> is enabled all the time and prints to log with debug level.
> 
> But your version
>   pr_debug("foo\n");
> defaults to being dropped until the system is built with dynamic
> debug, and that particular debug instance is enabled.
> 
> Since these are all useful, but low priority messages, not I
> don't think disabling them by default is such a great idea now.

Just had that discussion with David Miller.

http://marc.info/?l=linux-sctp&m=133710673230503&w=2
