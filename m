From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: unix: make some variables constant
Date: Mon, 18 Oct 2010 23:03:22 -0700
Message-ID: <20101018230322.490ac710@nehalam>
References: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47637 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab0JSGDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 02:03:24 -0400
In-Reply-To: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Oct 2010 13:24:02 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> And since ctl_table.data is initialized later, we don't need to initialize
> the data member of the template variable unix_table.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/unix/sysctl_net_unix.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
> index 397cffe..1114ccc 100644
> --- a/net/unix/sysctl_net_unix.c
> +++ b/net/unix/sysctl_net_unix.c
> @@ -15,10 +15,9 @@
>  
>  #include <net/af_unix.h>
>  
> -static ctl_table unix_table[] = {
> +const static ctl_table unix_table[] = {

Typical convention is "static const" rather than "const static"

git grep 'const static' | wc -l  => 5
git grep 'static const' | wc -l  => 18589

-- 
