From: "Dilger, Andreas" <andreas.dilger@intel.com>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Date: Mon, 9 Nov 2015 20:41:04 +0000
Message-ID: <D26652E2.1197DE%andreas.dilger@intel.com>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Russell King <linux@arm.linux.org.uk>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"drbd-user@lists.linbit.com" <drbd-user@lists.linbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"Drokin, Oleg" <oleg.drokin@intel.com>,
	"codalist@coda.cs.cmu.edu" <codalist@coda.cs.cmu.edu>,
	"linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
	Jan Kara <jack@suse.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Language: en-US
Content-ID: <994BD6192472F340B6785C8E6A9E1FA4@intel.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/11/09, 04:56, "Tetsuo Handa" <penguin-kernel@I-love.SAKURA.ne.jp>
wrote:

>There are many locations that do
>
>  if (memory_was_allocated_by_vmalloc)
>    vfree(ptr);
>  else
>    kfree(ptr);
>
>but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
>using is_vmalloc_addr(). Unless callers have special reasons, we can
>replace this branch with kvfree(). Please check and reply if you found
>problems.
>
>Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>Acked-by: Michal Hocko <mhocko@suse.com>

For Lustre part:
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Cheers, Andreas
-- 
Andreas Dilger

Lustre Principal Engineer
Intel High Performance Data Division


