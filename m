From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 03:02:32 -0800
Message-ID: <1354100552.14302.78.camel@edumazet-glaptop>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	 <50B4F2DA.8020206@hp.com>
	 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	 <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <1354089566.21562.20.camel@shinybook.infradead.org>
	 <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
	 <1354093703.21562.23.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36899 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab2K1LCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 06:02:35 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so9832930iea.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 03:02:35 -0800 (PST)
In-Reply-To: <1354093703.21562.23.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 09:08 +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 00:22 -0800, Vijay Subramanian wrote:
> > 
> > I don't believe reordering is tracked on the receiver side but on the
> > sender, there are SNMB_MIB items.
> > They can be tracked and can be viewed using nstat/netstat
> > 
> > # nstat -az | grep -i reorder
> > TcpExtTCPFACKReorder            0                  0.0
> > TcpExtTCPSACKReorder            0                  0.0
> > TcpExtTCPRenoReorder            0                  0.0
> > TcpExtTCPTSReorder              0                  0.0
> 
> Thanks. For me after a 64MiB download, I have an increase of one FACK,
> one SACK and one TS reorder. So my connection probably does even less
> reordering than I thought, and thus isn't particularly relevant to this
> conversation. I'll shut up now and go back to playing with ATM.

But you are the receiver. A receiver should not increase these counters.
