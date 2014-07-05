From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Sat, 5 Jul 2014 22:18:51 +0200
Message-ID: <20140705201851.GE3869@localhost.localdomain>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, richardcochran@gomail.com,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:58553 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbaGEUTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:19:14 -0400
Received: by mail-wi0-f177.google.com with SMTP id r20so5147925wiv.10
        for <netdev@vger.kernel.org>; Sat, 05 Jul 2014 13:19:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404416380-3545-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2014 at 03:39:33PM -0400, Willem de Bruijn wrote:

> +#define SCM_TSTAMP_SND		0x1	/* driver passed skb to NIC */
> +#define SCM_TSTAMP_ACK		0x2	/* transport layer saw ACK */
> +#define SCM_TSTAMP_ENQ		0x4	/* stack passed skb to TC layer */
> +#define SCM_TSTAMP_RCV		0x8	/* stack received skb */
> +#define SCM_TSTAMP_HWSYS	0x10	/* NIC tstamp in system format */

We don't need this flag. Better to omit it, because we are not going
to allow this kind of time stamp ever again.

> +#define SCM_TSTAMP_HWRAW	0x20	/* NIC tstamp in native format */

Thanks,
Richard
