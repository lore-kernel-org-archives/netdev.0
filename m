From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 00:22:34 -0800
Message-ID: <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	<50B4F2DA.8020206@hp.com>
	<CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	<20121127.210611.1127622873924794001.davem@davemloft.net>
	<1354089566.21562.20.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39066 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab2K1IWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 03:22:34 -0500
Received: by mail-ob0-f174.google.com with SMTP id wc20so11772347obb.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 00:22:34 -0800 (PST)
In-Reply-To: <1354089566.21562.20.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Short of going through whole dumps and looking, is there a good way to
> get statistics?
>

Hi David,

I don't believe reordering is tracked on the receiver side but on the
sender, there are SNMB_MIB items.
They can be tracked and can be viewed using nstat/netstat

# nstat -az | grep -i reorder
TcpExtTCPFACKReorder            0                  0.0
TcpExtTCPSACKReorder            0                  0.0
TcpExtTCPRenoReorder            0                  0.0
TcpExtTCPTSReorder              0                  0.0

Regards,
Vijay
