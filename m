From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] team: do RCU update path fixups
Date: Wed, 20 Jun 2012 21:14:03 +0200
Message-ID: <1340219643.4604.1641.camel@edumazet-glaptop>
References: <1340217579-1478-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757603Ab2FTTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 15:14:08 -0400
Received: by bkcji2 with SMTP id ji2so6563887bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 12:14:07 -0700 (PDT)
In-Reply-To: <1340217579-1478-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 20:39 +0200, Jiri Pirko wrote:
> Use rcu_access_pointer and rcu_dereference_protected
> to access RCU pointer by updater.
> Use RCU_INIT_POINTER for NULL assignment of RCU pointer.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/team/team_mode_activebackup.c |    8 ++++++--
>  drivers/net/team/team_mode_loadbalance.c  |   14 ++++++++++----
>  2 files changed, 16 insertions(+), 6 deletions(-)

Seems good to me, thanks.

Acked-by: Eric Dumazet <edumazet@google.com>
