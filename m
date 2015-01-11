From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 5/5] net-timestamp: tx timestamping default
 mode flag
Date: Sun, 11 Jan 2015 21:32:56 +0100
Message-ID: <20150111203256.GC4214@localhost.localdomain>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-6-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, luto@amacapital.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36846 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbAKUdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 15:33:01 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so10981175wiw.2
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 12:33:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420824719-28848-6-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 12:31:59PM -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> The number of timestamping points along the transmit path has grown,
> as have the options. Preferred behavior is to request timestamps with
> ID, without data (which enables batching) and for all supported
> timestamp points. Define a short option that enables all these
> defaults.

This "preferred behavior" is subjective, and it depends on the
application.  I am sure it reflects your own interest, but for people
doing PTP over UDP or raw, it is a bit misleading.

I would drop this default and just let applications define their own.

Thanks,
Richard
