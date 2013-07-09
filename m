From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: net/ipv4/route.c: Routing anomaly introduced by 89aef89 (ipv4:
 Delete routing cache.)
Date: Tue, 9 Jul 2013 12:28:02 +0300
Message-ID: <20130709122802.34831221@pixies.home.jungo.com>
References: <20130708113457.4a0d6023@pluto>
	<alpine.LFD.2.00.1307090832450.1621@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev@vger.kernel.org, eyal.birger@gmail.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:45659 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278Ab3GIJ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 05:28:13 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so3531387eaj.27
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 02:28:12 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1307090832450.1621@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Jul 2013 08:43:14 +0300 (EEST) Julian Anastasov <ja@ssi.bg> wrote:
> > It seems the omission of 'tos &= IPTOS_RT_MASK' from
> > 'ip_route_input_noref' was accidental.
> 
> 	Agreed
> 
> > We should align input/output behavior by reverting the omission, or
> > alternatively we may reconsider the entire IPTOS_RT_MASK thing.
> 
> 	The right thing should be to use tos &= IPTOS_RT_MASK
> at beginning of ip_route_input_noref.

Agreed. Will post a patch.

Regards,
Shmulik
