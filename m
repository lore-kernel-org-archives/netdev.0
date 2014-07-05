From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 7/8] net-timestamp: expand documentation
Date: Sat, 5 Jul 2014 22:14:29 +0200
Message-ID: <20140705201429.GD3869@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-8-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, richardcochran@gomail.com,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:54650 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbaGEUOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:51 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so5015685wib.3
        for <netdev@vger.kernel.org>; Sat, 05 Jul 2014 13:14:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404416380-3545-8-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2014 at 03:39:39PM -0400, Willem de Bruijn wrote:

> -hwtimetrans is the hardware time stamp transformed so that it
> +SCM_TSTAMP_HWRAW is the hardware time stamp transformed so that it
>  corresponds as good as possible to system time. This correlation is
>  not perfect; as a consequence, sorting packets received via different
>  NICs by their hwtimetrans may differ from the order in which they were

While we are at it, I would like to replace this text with something
like "legacy field, always zero."

Thanks,
Richard
