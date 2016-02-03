From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] flowi: add concept of "not_oif"
Date: Wed, 3 Feb 2016 22:02:05 +0100
Message-ID: <CAHmME9qqCZYvuskSQMA0F2d2E+5fHsRk=ydDOV=Nq5D7xemtaw@mail.gmail.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
	<1454521595-6721-1-git-send-email-Jason@zx2c4.com>
	<alpine.LFD.2.11.1602032149170.1802@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:60670 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745AbcBCVCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 16:02:10 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 8f68d1da
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 21:01:00 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id e6fdfe64
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 21:00:58 +0000 (UTC)
Received: by mail-wm0-f45.google.com with SMTP id r129so183800431wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:02:06 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1602032149170.1802@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

Thanks a lot for your review. Much appreciated.

On Wed, Feb 3, 2016 at 9:42 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         If you check every flowi4_oif user you will notice
> that some places can not fulfil this requirement:
> - fib_select_path -> fib_select_multipath
>         Other places like fib_select_default are called
> for flowi4_oif=0 and there are no other checks for flowi4_oif
> but they will be needed for the new field.
> fans, you have to check all places that use flowi4_oif and
> flowi6_oif.
> missing initialization of this new field

Thanks for pointing these out. I will take this into account and send
an updated patch [series].



>         I don't know about the particular problems with
> tunnels but the scripts can use the route metric to order
> the routes in a table.

This unfortunately does not cut it with tunnels.


Jason
