From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] configure: add missing INCLUDE to netnsid
 detection
Date: Fri, 10 Apr 2015 13:25:13 -0700
Message-ID: <20150410132513.6a8f20fa@urahara>
References: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34651 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbbDJUZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:25:08 -0400
Received: by pdbqa5 with SMTP id qa5so33148069pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:25:07 -0700 (PDT)
In-Reply-To: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Apr 2015 21:42:00 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> Fixes: d116ff34145b0 ("ip netns: Fix rtnl error while print netns list")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> The whole check added by d116ff34145b0 is dubious, though. This should be
> a run time check, not a compile time one.
> ---
>  configure | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure b/configure
> index 631938e97206..e54f4b6db5e8 100755
> --- a/configure
> +++ b/configure
> @@ -224,7 +224,7 @@ check_netnsid()
>  #include <linux/rtnetlink.h>
>  int test_def = RTM_GETNSID;
>  EOF
> -    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
> +    $CC -I$INCLUDE -c $TMPDIR/netnsid.c >/dev/null 2>&1
>      if [ $? -eq 0 ]
>      then
>  	echo "IP_CONFIG_NETNSID:=y" >> Config


Merged, but always up for a better solution in future.
