From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 07:53:27 +0900
Message-ID: <CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
 <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
 <CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com> <CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:61766 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758434AbaELWxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 18:53:48 -0400
Received: by mail-ie0-f170.google.com with SMTP id ar20so4253969iec.15
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 15:53:47 -0700 (PDT)
In-Reply-To: <CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 6:09 AM, sowmini varadhan <sowmini05@gmail.com> wrote:
> http://lwn.net/Articles/407495/, a single
> process should be able to open sockes in different namespaces.

Other things that you can't do with namespaces are have the same physical
interface (and the same IP address?) in two different namespaces, or
have the same listening socket in two different namespaces. Namespaces
are not a panacea.
