From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 04:58:21 +0900
Message-ID: <CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com> <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:56976 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaELT6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:58:42 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so516842ier.20
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:58:41 -0700 (PDT)
In-Reply-To: <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 9:21 PM, sowmini varadhan <sowmini05@gmail.com> wrote:
> what is the relationship
> between this proposal and the current linux vrf implementation

I'm not sure what you mean by VRF implementation, do you have a
pointer to the code?

> (which afaik is done using network namespaces)?

Socket marking is a per-socket operation, and a given process may have
many sockets with many different marks. I don't think it's possible to
do this using namespaces, because AFAIK a process can only be in one
namespace.
