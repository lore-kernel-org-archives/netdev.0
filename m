From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] e1000e: fix PTP on e1000_pch_lpt variants
Date: Wed, 20 Jul 2016 14:01:50 +0300
Message-ID: <347052e2-bca8-98b3-a35d-0f387b612e61@cogentembedded.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36254 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbcGTLB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 07:01:57 -0400
Received: by mail-lf0-f50.google.com with SMTP id g62so35557309lfe.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 04:01:54 -0700 (PDT)
In-Reply-To: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/19/2016 11:25 PM, Jarod Wilson wrote:

> I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
> as a PTP slave experiences random ~10 hour clock jumps, which are resolved
> if the same workaround for the 82574 and 82583 is employed. Switching from
> an if to a select, because the list of NIC types could well grow further

    s/select/switch/?

> and we'd already have to wrap the conditionals.
>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
[...]

MBR, Sergei
