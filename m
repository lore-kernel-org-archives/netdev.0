From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: [RFC][LAPB] write_queue limit in lapb_data_request
Date: Wed, 2 Apr 2008 13:50:17 +0400
Message-ID: <8496f91a0804020250o35e08732ya68e799550e074fa@mail.gmail.com>
References: <8496f91a0803250045k2fc4040dg74126f30c1487fd@mail.gmail.com>
	 <20080328.183052.72394821.davem@davemloft.net>
	 <8496f91a0803291311q705a0278hf1a437ab905dba7a@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:13740 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbYDBJuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 05:50:20 -0400
Received: by py-out-1112.google.com with SMTP id u52so3657028pyb.10
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 02:50:18 -0700 (PDT)
In-Reply-To: <8496f91a0803291311q705a0278hf1a437ab905dba7a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  > LAPB doesn't check for write_queue length in lapb_data_request(). So
>  > in some conditions it may grow unlimited. There is a potential problem
>  > for small systems.
>  >
>  > It seems like this for me:
>
>  It doesn't enforce limits on any of it's queued from what
>  I can tell.

I'm sorry. It's not quiet clear to me what you mean. As far as I know
LAPB internals there is only one place where write_queue may increase.
In other cases the ack_queue is used.

>
>  Without a thorough audit of resource limit enforcement in
>  this protocol stack, changing things here might be more
>  trouble than it's worth.
>

Thanks.
