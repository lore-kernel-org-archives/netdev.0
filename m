From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 2/2] netfilter/nflog: nflog-range does not truncate
 packets (userspace)
Date: Thu, 23 Jun 2016 19:42:23 +0200
Message-ID: <20160623174223.GA3648@salvia>
References: <20160621190216.GB6646@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pai.vishwain@gmail.com,
	ilubashe@akamai.com, jdollard@akamai.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160621190216.GB6646@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 03:02:16PM -0400, Vishwanath Pai wrote:
> netfilter/nflog: nflog-range does not truncate packets
> 
> The option --nflog-range has never worked, but we cannot just fix this
> because users might be using this feature option and their behavior would
> change. Instead add a new option --nflog-size. This option works the same
> way nflog-range should have, and both of them are mutually exclusive. When
> someone uses --nflog-range we print a warning message informing them that
> this feature has no effect.
> 
> To indicate the kernel that the user has set --nflog-size we have to pass a
> new flag XT_NFLOG_F_COPY_LEN.
> 
> Also updated the man page to reflect this.

Please, send me a v3 including tests, see:

        iptables/extensions/libxt_NFLOG.t

Thanks.
