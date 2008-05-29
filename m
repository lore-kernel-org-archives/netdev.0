From: "Dmitry Petukhov" <dmgenp@gmail.com>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in net/llc/llc_sap.c
Date: Thu, 29 May 2008 14:51:59 +0600
Message-ID: <84ee89da0805290151o500f1d5bg542f3ee9dff18be6@mail.gmail.com>
References: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
	 <483BB8EF.4090904@cn.fujitsu.com>
	 <84ee89da0805270047v1c76b4f3k5768fe853f2cea1d@mail.gmail.com>
	 <483BC1B0.2090600@cn.fujitsu.com>
	 <84ee89da0805270235t7ae75356la2ffbb5244de2f74@mail.gmail.com>
	 <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com>
	 <20080528201633.GK30251@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>,
	"Dmitry Petukhov" <dmgenp@gmail.com>,
	"Wei Yongjun" <yjwei@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:29716 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbYE2IwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:52:03 -0400
Received: by ti-out-0910.google.com with SMTP id b6so2195631tic.23
        for <netdev@vger.kernel.org>; Thu, 29 May 2008 01:52:01 -0700 (PDT)
In-Reply-To: <20080528201633.GK30251@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/29 Arnaldo Carvalho de Melo <acme@redhat.com>:

> Good catch, that code needs some revisiting after all these years...
> Anyway, can you please try this patch and report results?

problem disappear after patch applied.
