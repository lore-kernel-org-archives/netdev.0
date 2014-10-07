From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 11:50:35 -0700
Message-ID: <1412707835.11091.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	 <1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, Jesse Gross <jesse@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:55346 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbaJGSuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:50:37 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so5516002pdi.33
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 11:50:36 -0700 (PDT)
In-Reply-To: <CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 11:15 -0700, Alexei Starovoitov wrote:

> csum_partial() is in asm already. probably not much more can be squeezed.

Again this is wrong assumption. Its assembly and damn slow.

Take a look at commit 99f0b958b194f7d88973f1c2190d207e0a2c7e79
for details.
