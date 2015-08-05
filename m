From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next v3] openvswitch: Make 100 percents
 packets sampled when sampling rate is 1.
Date: Wed, 5 Aug 2015 11:06:03 -0700
Message-ID: <CALnjE+rmVbr+dDDpsqD4WX9fzSnNHVop8Ys==+h-dn+oYgNo+A@mail.gmail.com>
References: <1438759847-27666-1-git-send-email-wenyuz@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jgross@vmware.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Wenyu Zhang <wenyuz@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35861 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbHESGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 14:06:05 -0400
Received: by igbij6 with SMTP id ij6so100377872igb.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 11:06:03 -0700 (PDT)
In-Reply-To: <1438759847-27666-1-git-send-email-wenyuz@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 5, 2015 at 12:30 AM, Wenyu Zhang <wenyuz@vmware.com> wrote:
> When sampling rate is 1, the sampling probability is UINT32_MAX. The packet
> should be sampled even the prandom32() generate the number of UINT32_MAX.
> And none packet need be sampled when the probability is 0.
>
> Signed-off-by: Wenyu Zhang <wenyuz@vmware.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.
