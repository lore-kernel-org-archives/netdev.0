From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: ipv6: more places need LOOPBACK_IFINDEX for
 flowi6_iif
Date: Tue, 29 Apr 2014 07:50:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404290747350.1508@ja.home.ssi.bg>
References: <1398671516-8842-1-git-send-email-ja@ssi.bg> <CAHA+R7PXpweyfVMuGazCvHFXTRX-SGGjuXcU1tM-yy+oX1f=ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33015 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753712AbaD2Evf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 00:51:35 -0400
In-Reply-To: <CAHA+R7PXpweyfVMuGazCvHFXTRX-SGGjuXcU1tM-yy+oX1f=ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 28 Apr 2014, Cong Wang wrote:

> On Mon, Apr 28, 2014 at 12:51 AM, Julian Anastasov <ja@ssi.bg> wrote:
> > To properly match iif in ip rules we have to provide
> > LOOPBACK_IFINDEX in flowi6_iif, not 0. Some ip6mr_fib_lookup
> > and fib6_rule_lookup callers need such fix.
> >
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Maybe ip6_mr_input() and pim6_rcv() too?

	They are ok, flowi6_iif contains the input device.

Regards

--
Julian Anastasov <ja@ssi.bg>
