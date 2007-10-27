From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sat, 27 Oct 2007 15:40:04 -0700
Message-ID: <1193524804.26695.103.camel@localhost>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1745 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbXJ0Wk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2007 18:40:29 -0400
In-Reply-To: <20071027194758.GD9816@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-10-27 at 23:47 +0400, Alexey Dobriyan wrote:
> Remove proc_fs.h from headers that doesn't really need it.

> --- a/arch/powerpc/kernel/process.c
> +++ b/arch/powerpc/kernel/process.c
> @@ -17,6 +17,7 @@
>  #include <linux/errno.h>
>  #include <linux/sched.h>
>  #include <linux/kernel.h>
> +#include <linux/fs.h>

Your code doesn't match your patch description.

You've got new includes of:

<linux/fs.h>
<linux/proc_fs.h>
<linux/err.h>
<linux/kref.h>

and forward declarations of

struct proc_dir_entry;
struct file_operations;

As a general rule, I think it better to use includes
than use naked forward declarations.


