From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 right-most SACK block
Date: Tue, 07 Jun 2016 08:21:01 -0700
Message-ID: <1465312861.24873.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CADVnQymeArQhGTUFuTXQb4v3aabzseumybjpJ8UtTugnX=2=cA@mail.gmail.com>
	 <1465309834-31942-1-git-send-email-pau.espin@tessares.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: Pau Espin Pedrol <pau.espin@tessares.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32934 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcFGPVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 11:21:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id u67so4635797pfu.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 08:21:03 -0700 (PDT)
In-Reply-To: <1465309834-31942-1-git-send-email-pau.espin@tessares.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-07 at 16:30 +0200, Pau Espin Pedrol wrote:
> RFC 5961 advises to only accept RST packets containing a seq number
> matching the next expected seq number instead of the whole receive
> window in order to avoid spoofing attacks.

> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
