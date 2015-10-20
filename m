From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv3 net 3/4] openvswitch: Mark connections new when not
 confirmed.
Date: Tue, 20 Oct 2015 10:41:26 +0200
Message-ID: <20151020084126.GB25435@pox.localdomain>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
 <1445307540-6786-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jrajahalme@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34832 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbJTIl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 04:41:29 -0400
Received: by wicll6 with SMTP id ll6so34230916wic.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 01:41:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445307540-6786-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/15 at 07:18pm, Joe Stringer wrote:
> New, related connections are marked as such as part of ovs_ct_lookup(),
> but they are not marked as "new" if the commit flag is used. Make this
> consistent by setting the "new" flag whenever !nf_ct_is_confirmed(ct).
> 
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Acked.
> v3: Took a different approach to fixing the issue.

Acked-by: Thomas Graf <tgraf@suug.ch>
