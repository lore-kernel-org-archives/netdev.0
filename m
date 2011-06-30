From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 0/4] dynamic_debug
Date: Thu, 30 Jun 2011 15:51:39 -0400
Message-ID: <20110630195139.GC2457@redhat.com>
References: <20110630163218.GA2457@redhat.com>
 <cover.1309457340.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg@kroah.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1309457340.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 30, 2011 at 11:14:33AM -0700, Joe Perches wrote:
> Some improvements and cleanups to dynamic_debug
> 
> btw Jason:
> 
> You're not listed in MAINTAINERS for dynamic_debug.[ch].
> Maybe you should add yourself. 
> 

Yes, I need to do that.

Thanks,

-Jason


> Joe Perches (4):
>   dynamic_debug: Add __dynamic_dev_dbg
>   dynamic_debug: Consolidate prefix output to single routine
>   dynamic_debug: Remove uses of KERN_CONT in dynamic_emit_prefix
>   dynamic_debug: Convert printks to pr_<level>
> 
>  drivers/base/core.c           |    5 +-
>  include/linux/device.h        |    5 ++
>  include/linux/dynamic_debug.h |   10 +++-
>  lib/dynamic_debug.c           |  133 +++++++++++++++++++++++++++--------------
>  4 files changed, 103 insertions(+), 50 deletions(-)
> 
> -- 
> 1.7.6.rc1
> 
