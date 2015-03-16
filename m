From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: Stable inclusion request: recvmsg/sendmsg userspace regression
 fix
Date: Mon, 16 Mar 2015 10:43:12 +0100
Message-ID: <5506A5B0.4020301@suse.cz>
References: <54CBA338.1000207@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@arista.com>, Stable Tree <stable@vger.kernel.org>
To: Michal Marek <mmarek@suse.cz>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54CBA338.1000207@suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2015, 04:28 PM, Michal Marek wrote:
> Hi,
> 
> please include
> 
> commit 6a2a2b3ae0759843b22c929881cc184b00cc63ff
> Author: Ani Sinha <ani@arista.com>
> Date:   Mon Sep 8 14:49:59 2014 -0700
> 
>     net:socket: set msg_namelen to 0 if msg_name is passed as NULL in
> msghdr struct from userland.
> 
> to 3.14.y and older trees, since it fixes a userspace regression caused
> by commit dbb490b9 ("net: socket: error on a negative msg_namelen"). The
> patch applies cleanly to all trees down to 2.6.32.y.

Hi,

this was not in the last batch of fixes yet. David, do you have any
plans with this one?

thanks,
-- 
js
suse labs
