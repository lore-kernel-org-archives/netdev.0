From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net 3/3] openvswitch: Serialize nested ct actions if
 provided
Date: Sat, 17 Oct 2015 09:54:17 +0200
Message-ID: <20151017075417.GD13981@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33287 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbJQHyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 03:54:19 -0400
Received: by wijp11 with SMTP id p11so37324863wij.0
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 00:54:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445018901-18839-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 11:08am, Joe Stringer wrote:
> If userspace provides a ct action with no nested mark or label, then the
> storage for these fields is zeroed. Later when actions are requested,
> such zeroed fields are serialized even though userspace didn't
> originally specify them. Fix the behaviour by ensuring that no action is
> serialized in this case, and reject actions where userspace attempts to
> set these fields with mask=0. This should make netlink marshalling
> consistent across deserialization/reserialization.
> 
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
