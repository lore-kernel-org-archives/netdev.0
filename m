From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 0/2] net: fix race in the receive/select
Date: Wed, 08 Jul 2009 20:07:30 -0700 (PDT)
Message-ID: <20090708.200730.157501893.davem@davemloft.net>
References: <20090708220717.GB2945@jolsa.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@polymtl.ca, mingo@elte.hu,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, htejun@gmail.com,
	jarkao2@gmail.com, oleg@redhat.com, davidel@xmailserver.org
To: jolsa@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421AbZGIDH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 23:07:27 -0400
In-Reply-To: <20090708220717.GB2945@jolsa.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Olsa <jolsa@redhat.com>
Date: Thu, 9 Jul 2009 00:07:17 +0200

> This patchset fixies the race within the poll_wait call and the receive callbacks,
> by adding memory barrier.
> 
> - 1/2 includes the actual fix
> - 2/2 includes optimization for the x86 arch

Eric, can I have your signoffs for these?

Thanks!
