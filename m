From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 4/6] sctp: add the sctp_diag.c file
Date: Sat, 09 Apr 2016 10:23:56 -0700
Message-ID: <1460222636.6473.494.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
	 <a3703f4379eeb3a385d3cc000dd621f77540608e.1460177331.git.lucien.xin@gmail.com>
	 <5408d667c2a83b8917a501b92810c82f9a66f584.1460177331.git.lucien.xin@gmail.com>
	 <ac19f4966c7df6399c2a3bfa0f7f9589b9ff536f.1460177331.git.lucien.xin@gmail.com>
	 <1460181116.6473.483.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CADvbK_dZDDCpEm-RF_Zv3Xq6kvnfGnnk822cON5rUJPo-R8Y4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33466 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbcDIRYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:24:00 -0400
In-Reply-To: <CADvbK_dZDDCpEm-RF_Zv3Xq6kvnfGnnk822cON5rUJPo-R8Y4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-09 at 23:40 +0800, Xin Long wrote:

> you meant we can remove it here ?
> yes, it seems similar with INET_DIAG_SKMEMINFO.
> but I do not know if userpace may use  INET_DIAG_MEMINFO now.
> 

You are adding new features here. No problem of legacy code.

Anyway, as I said you really need to reuse code, not copy paste please.
