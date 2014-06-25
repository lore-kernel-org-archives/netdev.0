From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 0/2] bridge: more efficient fdb dumping
Date: Wed, 25 Jun 2014 06:25:17 -0400
Message-ID: <53AAA38D.8090808@mojatatu.com>
References: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:45304 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbaFYKZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 06:25:26 -0400
Received: by mail-ie0-f181.google.com with SMTP id y20so1441397ier.40
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 03:25:25 -0700 (PDT)
In-Reply-To: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I should say I have tested this version against net-next
(the commit message describes the validation tests)

cheers,
jamal

On 06/25/14 06:21, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Changes:
> V3:
>   Suggestion from Eric D. to use for_each_netdev
>   Suggestion from Stephen H. to reduce level of indentation
>
> V2:
> Suggestions from Vlad
>   Get rid of rcu read lock since rtnl_lock is being held
>   simplify for readability
>
>
> Jamal Hadi Salim (2):
>    bridge: fdb dumping takes a filter device
>    bridge: netlink dump interface at par with brctl
>
>   drivers/net/ethernet/intel/i40e/i40e_main.c      |    3 +-
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 +-
>   include/linux/netdevice.h                        |    1 +
>   include/linux/rtnetlink.h                        |    1 +
>   net/bridge/br_fdb.c                              |   14 ++++
>   net/bridge/br_private.h                          |    2 +-
>   net/core/rtnetlink.c                             |   77 +++++++++++++++++-----
>   7 files changed, 84 insertions(+), 19 deletions(-)
>
