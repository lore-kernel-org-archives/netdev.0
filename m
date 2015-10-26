From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2] net/mlx4: Memcpy at slave_event should copy sizeof mlx4_eqe
Date: Mon, 26 Oct 2015 19:02:46 +0200
Message-ID: <CAJ3xEMgFjen8EY6WX3Zpk1k4pAou=HF8ZZHVVnaUtwePAZrcUg@mail.gmail.com>
References: <1445872540-18605-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Carol L Soto <clsoto@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36066 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbbJZRCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:02:47 -0400
Received: by ioll68 with SMTP id l68so194204899iol.3
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 10:02:46 -0700 (PDT)
In-Reply-To: <1445872540-18605-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 5:15 PM,  <clsoto@linux.vnet.ibm.com> wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>
> If the caps.eqe_size is bigger than the struct mlx4_eqe then there
> is a potential for corrupting data at the master context. We can see
> the message "Master failed to generate an EQE for slave: X" when the
> event_eqe array wraps and we can see potential oops at the function
> mlx4_GEN_EQE. Also correct a memset of cmd_eqe to use the sizeof
> mlx4_eqe instead of eqe_size.
>
> Fixes: 08ff32352d6f ('mlx4: 64-byte CQE/EQE support')
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Thanks Carol, I'd like to review this a bit more tomorrow and will
send it with another fix/es to net
