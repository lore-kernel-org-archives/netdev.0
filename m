From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/7] be2net: Enable RSS UDP hashing for Lancer
 and Skyhawk
Date: Thu, 12 Jul 2012 16:10:15 +0200
Message-ID: <1342102215.3265.8263.camel@edumazet-glaptop>
References: <58046138-832a-49a2-84a8-fa682a74162e@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59477 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522Ab2GLOKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:10:20 -0400
Received: by bkwj10 with SMTP id j10so2178793bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 07:10:19 -0700 (PDT)
In-Reply-To: <58046138-832a-49a2-84a8-fa682a74162e@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 19:27 +0530, Padmanabh Ratnakar wrote:
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be.h      |    3 +++
>  drivers/net/ethernet/emulex/benet/be_cmds.c |    7 +++++++
>  drivers/net/ethernet/emulex/benet/be_cmds.h |    2 ++
>  3 files changed, 12 insertions(+), 0 deletions(-)

It would be nice to add a bit of documentation on this, and what
components are used from the tuple (dst addr, src addr, dst port, src
port)
