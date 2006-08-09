From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Wed, 9 Aug 2006 10:47:38 -0700
Message-ID: <20060809104738.1498723f@localhost.localdomain>
References: <11551105592821@2ka.mipt.ru>
	<11551105602734@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47279 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751273AbWHIRsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 13:48:23 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11551105602734@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Aug 2006 12:02:40 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> 
> Core files.
> 
> This patch includes core kevent files:
>  - userspace controlling
>  - kernelspace interfaces
>  - initialization
>  - notification state machines
> 
> It might also inlclude parts from other subsystem (like network related
> syscalls, so it is possible that it will not compile without other
> patches applied).
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> 
> +#ifdef CONFIG_KEVENT_USER_STAT
> +static inline void kevent_user_stat_init(struct kevent_user *u)
> +{
> +	u->wait_num = u->im_num = u->total = 0;
> +}
> +static inline void kevent_user_stat_print(struct kevent_user *u)
> +{
> +	pr_debug("%s: u=%p, wait=%lu, immediately=%lu, total=%lu.\n", 
> +			__func__, u, u->wait_num, u->im_num, u->total);
> +}
> +static inline void kevent_user_stat_increase_im(struct kevent_user *u)
> +{
> +	u->im_num++;
> +}
> +static inline void kevent_user_stat_increase_wait(struct kevent_user *u)
> +{
> +	u->wait_num++;
> +}
> +static inline void kevent_user_stat_increase_total(struct kevent_user *u)
> +{
> +	u->total++;
> +}
>

static wrapper_functions_with_execessive_long_names(struct i_really_hate *this)
{
	suck();
}
