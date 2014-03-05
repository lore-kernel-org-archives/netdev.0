From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: Improve SO_TIMESTAMPING documentation and fix a
 minor code bug
Date: Wed, 5 Mar 2014 09:12:45 +0100
Message-ID: <20140305081245.GA4287@netboy>
References: <ea5365bea8a03800609443cae8dce71eb89e78f4.1393982607.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:34100 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbaCEIM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:12:58 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so257680eei.28
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 00:12:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ea5365bea8a03800609443cae8dce71eb89e78f4.1393982607.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 05:24:10PM -0800, Andy Lutomirski wrote:
> The original documentation was very unclear.
> 
> The code fix is presumably related to the formerly unclear
> documentation: SOCK_TIMESTAMPING_RX_SOFTWARE has no effect on
> __sock_recv_timestamp's behavior, so calling __sock_recv_ts_and_drops
> from sock_recv_ts_and_drops if only SOCK_TIMESTAMPING_RX_SOFTWARE is
> set is pointless.  This should have no user-observable effect.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---

Acked-by: Richard Cochran <richardcochran@gmail.com>
