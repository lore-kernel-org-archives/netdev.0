From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 21:21:39 +0200
Message-ID: <1349119299.12401.719.camel@edumazet-glaptop>
References: <1348779826.5093.1750.camel@edumazet-glaptop>
	 <1348780624.5093.1767.camel@edumazet-glaptop>
	 <50656C4A.8090302@googlemail.com>
	 <1348831592.5093.2251.camel@edumazet-glaptop>
	 <5068648C.7050005@googlemail.com>
	 <1349034330.12401.210.camel@edumazet-glaptop>
	 <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <5069B300.9080308@googlemail.com>
	 <1349105498.12401.706.camel@edumazet-glaptop>
	 <20121001183452.GA4492@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Clayton <chris2553@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Captain Obvious <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56010 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab2JATVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 15:21:47 -0400
Received: by bkcjk13 with SMTP id jk13so5166603bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 12:21:46 -0700 (PDT)
In-Reply-To: <20121001183452.GA4492@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 20:34 +0200, Captain Obvious wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
> > > > Could you send
> > > >
> > > > iptables -t -nat -nvL
> > > 
> > > $ iptables -t -nat -nvL
>                   ^ typo
> 
> Please try "iptables -t nat -nvL" as was also suggested.
> 

Oh well, good catch ;)

And for conntrack -L, please Chris add CONFIG_NF_CT_NETLINK=m to your
kernel .config
