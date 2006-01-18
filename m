From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Re: net 2.6.16-rc1: multiple ipv6 failures
Date: Wed, 18 Jan 2006 09:40:09 +0000
Message-ID: <43CE0CF9.2030003@thekelleys.org.uk>
References: <43CDAA58.5000904@pobox.com> <20060117.214750.37718950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932147AbWARJkN@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <20060117.214750.37718950.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Known problem, fixed by Yoshifuji in current GIT.  /proc/net/if_net6's
> output format got mistakedly changed, and this confused named and
> ifconfig, among other things.

For reference, add dnsmasq to the list of confused userspace: the 
signature error is:

failed to find list of interfaces: No such device

Cheers,

Simon.
