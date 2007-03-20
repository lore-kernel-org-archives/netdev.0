From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PKT_SCHED] atm: Fix missing net/netlink.h include after nlmsg_trim() cleanup
Date: Tue, 20 Mar 2007 19:27:38 -0300
Message-ID: <39e6f6c70703201527k5ba5f83h40a0341ce06e4cc4@mail.gmail.com>
References: <20070320220225.GP521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:19224 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbXCTW1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:27:44 -0400
Received: by ug-out-1314.google.com with SMTP id 44so35065uga
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:27:39 -0700 (PDT)
In-Reply-To: <20070320220225.GP521@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/20/07, Thomas Graf <tgraf@suug.ch> wrote:
> sch_atm.c:(.text+0x380ed): undefined reference to `nlmsg_trim'
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
> diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
> index 53060e6..daa1644 100644
> --- a/net/sched/sch_atm.c
> +++ b/net/sched/sch_atm.c
> @@ -12,8 +12,8 @@
>  #include <linux/atmdev.h>
>  #include <linux/atmclip.h>
>  #include <linux/netdevice.h>
> -#include <linux/rtnetlink.h>
>  #include <linux/file.h> /* for fput */
> +#include <net/netlink.h>
>  #include <net/pkt_sched.h>
>  #include <net/sock.h>

Hey, if it wasn't for Dave to state that he would be out in la-la land
for three days you wouldn't have the opportunity to figure that I made
a mistake :-)

I noticed that shortly after I made that mistake, but have to wait for
boss to get back at his super merging abilities :-)

- Arnaldo
