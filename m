From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] net-timestamp: SOCK_RAW and PING timestamping
Date: Tue, 15 Jul 2014 08:30:10 +0200
Message-ID: <20140715063010.GA4087@localhost.localdomain>
References: <1405374906-4657-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:64073 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668AbaGOGac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:30:32 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so3517478wiv.4
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 23:30:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405374906-4657-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 05:55:06PM -0400, Willem de Bruijn wrote:
> Add SO_TIMESTAMPING to sockets of type PF_INET[6]/SOCK_RAW:
> 
> Add the necessary sock_tx_timestamp calls to the datapath for RAW
> sockets (ping sockets already had these calls).
> 
> Fix the IP output path to pass the timestamp flags on the first
> fragment also for these sockets. The existing code relies on
> transhdrlen != 0 to indicate a first fragment. For these sockets,
> that assumption does not hold.
> 
> This fixes http://bugzilla.kernel.org/show_bug.cgi?id=77221
> 
> Tested SOCK_RAW on IPv4 and IPv6, not PING.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
