From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Date: Mon, 09 Nov 2015 22:48:37 +0100
Message-ID: <5253459.IxnqkcU2vL@vostro.rjw.lan>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Boris Petkov <bp@suse.de>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Monday, November 09, 2015 08:56:10 PM Tetsuo Handa wrote:
> There are many locations that do
> 
>   if (memory_was_allocated_by_vmalloc)
>     vfree(ptr);
>   else
>     kfree(ptr);
> 
> but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
> using is_vmalloc_addr(). Unless callers have special reasons, we can
> replace this branch with kvfree(). Please check and reply if you found
> problems.

ACK for the ACPI changes (and CCing Tony and Boris for the heads-up as they
are way more famailiar with the APEI code than I am).

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
