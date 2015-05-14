From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 14:55:22 -0700
Message-ID: <1431640522.27831.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514212855.1301.93235.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36221 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933547AbbENVzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:55:24 -0400
Received: by iepk2 with SMTP id k2so71469899iep.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 14:55:23 -0700 (PDT)
In-Reply-To: <20150514212855.1301.93235.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 14:31 -0700, Alexander Duyck wrote:
> The rx_dropped stat wasn't being reported when ip_tunnel_get_stats64 was
> called.  This was leading to some confusing results in my debug as I was
> seeing rx_errors increment but no other value which pointed me toward the
> type of error being seen.
> 
> This change corrects that by using netdev_stats_to_stats64 to copy all
> available dev stats instead of just the few that were hand picked.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---

Signed-off-by: Eric Dumazet <edumazet@google.com>
