From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [patch] hamradio/kiss: missing error code in mkiss_open()
Date: Mon, 10 Aug 2015 21:32:20 -0300
Message-ID: <CAOMZO5Az=v+gFVMyaJ4JMPcDh8_LQ-_vwiA2rKB_N4ZKrtzyVg@mail.gmail.com>
References: <CA+55aFy1af43uxH1r=_CxTCgPNN802YA+H26Vbbkb=rknqZuXQ@mail.gmail.com>
	<20150810213922.GA3380@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	RUC_Soft_Sec <zy900702@163.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33955 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbbHKAcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 20:32:21 -0400
Received: by oip136 with SMTP id 136so95121186oip.1
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 17:32:20 -0700 (PDT)
In-Reply-To: <20150810213922.GA3380@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 6:39 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> If register_netdev() fails we return success but we should return an
> error code instead.
>
> Reported-by: RUC_Soft_Sec <zy900702@163.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

I have also sent a similar one:
https://patchwork.ozlabs.org/patch/505758/
