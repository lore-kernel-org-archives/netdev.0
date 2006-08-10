From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/5] socket: code style cleanup
Date: Thu, 10 Aug 2006 01:19:50 -0700
Message-ID: <20060810011950.0a56760a.akpm@osdl.org>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183349.177095462@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61627 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751470AbWHJIXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 04:23:35 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060809183349.177095462@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Aug 2006 11:31:40 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Make socket.c conform to current style:
> 	* run through Lindent
> 	* get rid of unneeded casts
> 	* split assignment and comparsion where possible
> 

<stares at a stream of rejects.  Sighs>

> -static ssize_t sock_aio_read(struct kiocb *iocb, char __user *buf,
> -			 size_t size, loff_t pos);
> -static ssize_t sock_aio_write(struct kiocb *iocb, const char __user *buf,
> -			  size_t size, loff_t pos);
> -static int sock_mmap(struct file *file, struct vm_area_struct * vma);
> +static ssize_t sock_aio_read(struct kiocb *iocb, char __user * buf,
> +			     size_t size, loff_t pos);
> +static ssize_t sock_aio_write(struct kiocb *iocb, const char __user * buf,
> +			      size_t size, loff_t pos);
> +static int sock_mmap(struct file *file, struct vm_area_struct *vma);

The s/ *buf/ * buf/ is inconsistent, illogical and, IMO, wrong.

<goes off to fix the rejects>
