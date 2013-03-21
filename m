From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Thu, 21 Mar 2013 13:46:26 -0400 (EDT)
Message-ID: <20130321.134626.486899185375222307.davem@davemloft.net>
References: <CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com>
	<514AA946.6020603@redhat.com>
	<CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab3CURq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:46:29 -0400
In-Reply-To: <CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 21 Mar 2013 13:27:51 -0400

> Unfortunately, I don't have the hardware to verify, but it still
> passes on my platforms.

I think you do, simply build your test program with "gcc -m32"
and run it on your x86_64 machine.

But in any event I'll test your change too.
