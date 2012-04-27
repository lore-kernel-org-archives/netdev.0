From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: ip_vs_ftp.c: local functions should not be exposed
 globally
Date: Fri, 27 Apr 2012 10:01:40 +0900
Message-ID: <20120427010140.GD5105@verge.net.au>
References: <201204261126.15699.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201204261126.15699.hartleys@visionengravers.com>
 <201204261117.28491.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2012 at 11:17:28AM -0700, H Hartley Sweeten wrote:
> Functions not referenced outside of a source file should be marked
> static to prevent it from being exposed globally.
> 
> This quiets the sparse warnings:
> 
> warning: symbol 'ip_vs_ftp_init' was not declared. Should it be static?

On Thu, Apr 26, 2012 at 11:26:15AM -0700, H Hartley Sweeten wrote:
> Functions not referenced outside of a source file should be marked
> static to prevent it from being exposed globally.
> 
> This quiets the sparse warnings:
> 
> warning: symbol '__ipvs_proto_data_get' was not declared. Should it be static?
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: "David S. Miller" <davem@davemloft.net>

Thanks, I have applied these to ipvs-next.

git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git
