From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Mon, 16 Jun 2014 20:44:04 -0400
Message-ID: <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
	<20140616211954.6E12BA3A89@unicorn.suse.cz>
	<CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
	<CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
	<CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34444 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbaFQAoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 20:44:06 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so6090394wib.3
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 17:44:04 -0700 (PDT)
In-Reply-To: <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 8:25 PM, Yuchung Cheng <ycheng@google.com> wrote:
> However Linux is inconsistent on the loss of a retransmission. It
> reduces ssthresh (and cwnd) if this happens on a timeout, but not in
> fast recovery (tcp_mark_lost_retrans). We should fix that and that
> should help dealing with traffic policers.

Yes, great point!

neal
