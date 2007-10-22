From: "Wenhua Zhao" <whzhao@gmail.com>
Subject: Re: attach additional value to skb
Date: Mon, 22 Oct 2007 14:18:44 -0700
Message-ID: <178ddfde0710221418v435c9f45ie6d8cb9b7bebd288@mail.gmail.com>
References: <f36b08ee0710221303y5a846a27v1ebdc919db0f00ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:33702 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbXJVVSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 17:18:45 -0400
Received: by py-out-1112.google.com with SMTP id u77so2735940pyb
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:18:44 -0700 (PDT)
In-Reply-To: <f36b08ee0710221303y5a846a27v1ebdc919db0f00ac@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/07, Yakov Lerner <iler.ml@gmail.com> wrote:
> 1. How can I attach my 32-bit value to the skb in the
> PRE_ROUTNIG hook such that FORWARD and POST_ROUTING
> hooks can later access this value from the skb ?
>
> Can I use sk_buff->cb for that ?
In IP layer cb is used by IP as structure inet_skb_param.  It is
written by ip_rcv_options() (in function ip_rcv_finish()) between
PRE_ROUTING and FORWARD/POST_ROUTING.

In my opinion, cb is only used when one exclusively owns the skb.

Regards,
Wenhua
