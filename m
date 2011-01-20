From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 00/79] netfilter: netfilter update
Date: Thu, 20 Jan 2011 01:59:36 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101200157310.9228@obet.zrqbmnf.qr>
References: <1295464519-21763-1-git-send-email-kaber@trash.net> <20110119.135504.149816150.davem@davemloft.net> <20110119.165045.25148392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110119.165045.25148392.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2011-01-20 01:50, David Miller wrote:
>> 
>>> Please pull from
>>> 
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master
>> 
>> Pulled, thanks.
>
>I'm undoing my pull, what was this build tested against?
>In particular this commit breaks the build:
>
>Subject: [PATCH 68/79] netfilter: xtables: add missing header files to export list
>
>Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ...
>@@ -56,6 +56,8 @@ header-y += xt_rateest.h
> header-y += xt_realm.h
> header-y += xt_recent.h
> header-y += xt_sctp.h
>+header-y += xt_secmark.h
>+header-y += xt_socket.h
> header-y += xt_state.h
> header-y += xt_statistic.h
> header-y += xt_string.h
>
>No active tree has a include/linux/netfilter/xt_secmark.h file.  Therefore
>we end up with:
>
>make[2]: `scripts/unifdef' is up to date.
>make[4]: *** No rule to make target `/home/davem/src/GIT/net-next-2.6/include/linux/netfilter/xt_secmark.h', needed by `/home/davem/src/GIT/net-next-2.6/usr/include/linux/netfilter/.install'.  Stop.
>
>Did you mean xt_SECMARK.h (caps)?

My git was weak there. The lower-case secmark line should just be removed.
