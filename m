From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/7] inet: add ireq_state field to
 inet_request_sock
Date: Thu, 12 Mar 2015 15:54:05 -0700
Message-ID: <1426200845.11398.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
	 <1426197016-14482-3-git-send-email-edumazet@google.com>
	 <20150312.184104.1561012099436884851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36628 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbCLWyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 18:54:07 -0400
Received: by iegc3 with SMTP id c3so67809196ieg.3
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 15:54:06 -0700 (PDT)
In-Reply-To: <20150312.184104.1561012099436884851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 18:41 -0400, David Miller wrote:

> The write_pnet() and atomic64_set() calls in these hunks seem
> completely unrelated to this change, and are in fact bug fixes.

Oh right, I can split this.
