From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] neigh: print nud_state in neigh timer handler.
Date: Wed, 2 Nov 2011 00:05:50 +0200
Message-ID: <CAEnQRZDPWcv8_YeuhVaUiJqnyJNFRm-=+dZiKepHtLU-LTZqRg@mail.gmail.com>
References: <1320095448-5228-1-git-send-email-dbaluta@ixiacom.com>
	<20111101.174411.1200019350687608200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:51717 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab1KAWFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 18:05:51 -0400
Received: by qyk4 with SMTP id 4so5388759qyk.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 15:05:50 -0700 (PDT)
In-Reply-To: <20111101.174411.1200019350687608200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2011 at 11:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Mon, 31 Oct 2011 23:10:48 +0200
>
>> From: Daniel Baluta <daniel.baluta@gmail.com>
>>
>> For debugging purposes it is useful to know the exact state of a
>> non NUD_IN_TIMER neighbour entry whose timer handler just expired.
>>
>> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
>
> This debugging log message is dubious.
>
> Also, it is protected by !SMP and I can almost guarentee you that whatever
> condition makes it happen leigitmately on SMP also can be triggered with
> preemption enabled on !SMP.
>
> So I'm going to simply remove this debug message entirely instead.

Agree. If you can figure out when this condition is true, it is nice
to have a comment.

Daniel.
