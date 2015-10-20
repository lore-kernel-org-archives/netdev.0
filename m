From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net 3/4] openvswitch: Mark connections new when not confirmed.
Date: Tue, 20 Oct 2015 15:07:38 -0700
Message-ID: <CALnjE+qBx3OJ0RKFhnhLX7Z2_=MO8aFM5jeBoJ+PL7coUx=ctQ@mail.gmail.com>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
	<1445307540-6786-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37587 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbbJTWHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 18:07:38 -0400
Received: by igbhv6 with SMTP id hv6so25159263igb.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 15:07:38 -0700 (PDT)
In-Reply-To: <1445307540-6786-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 7:18 PM, Joe Stringer <joestringer@nicira.com> wrote:
> New, related connections are marked as such as part of ovs_ct_lookup(),
> but they are not marked as "new" if the commit flag is used. Make this
> consistent by setting the "new" flag whenever !nf_ct_is_confirmed(ct).
>
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
