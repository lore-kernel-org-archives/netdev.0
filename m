From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net 3/3] openvswitch: Serialize nested ct actions if provided
Date: Fri, 16 Oct 2015 12:03:29 -0700
Message-ID: <CALnjE+pEEuprPwfs8PThs=BL3x5XcYGoKXE7ZN8XA8wf_0xuFA@mail.gmail.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
	<1445018901-18839-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36362 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbJPTDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 15:03:30 -0400
Received: by ioii196 with SMTP id i196so133330483ioi.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 12:03:29 -0700 (PDT)
In-Reply-To: <1445018901-18839-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 11:08 AM, Joe Stringer <joestringer@nicira.com> wrote:
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

Acked-by: Pravin B Shelar <pshelar@nicira.com>
