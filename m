From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] iptables: xt_recent: Add optional mask option for
 xt_recent
Date: Sat, 14 Jul 2012 17:05:27 +0200
Message-ID: <20120714150527.GA6271@1984>
References: <1337285337-13619-1-git-send-email-denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	Linux netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337285337-13619-1-git-send-email-denys@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Denys,

On Thu, May 17, 2012 at 11:08:57PM +0300, Denys Fedoryshchenko wrote:
> Use case for this feature:
> 1)In some occasions if you need to allow,block,match specific subnet.
> 2)I can use recent as a trigger when netfilter rule matches, with mask 0.0.0.0
> 
> Tested for backward compatibility:
> )old (userspace) iptables, new kernel
> )old kernel, new iptables
> )new kernel, new iptables

I've cleaned up this patch:

http://git.netfilter.org/cgi-bin/gitweb.cgi?p=iptables.git;a=commit;h=73bf03981dfaee48ac1d6da380d46501a96cc83e

It's not yet in master. Please, check that this is correct.

BTW, the man page update is still missing.
