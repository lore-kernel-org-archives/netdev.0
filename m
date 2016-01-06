From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 05 Jan 2016 19:02:36 -0800
Message-ID: <1452049356.8255.155.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
	 <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <568C6972.8020908@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com, tglx@linutronix.de,
	mingo@redhat.com, x86@kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33040 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcAFDCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 22:02:38 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so194684257pfb.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 19:02:38 -0800 (PST)
In-Reply-To: <568C6972.8020908@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 17:10 -0800, H. Peter Anvin wrote:

> Apparently "adcq.d8" will do The Right Thing for this.

Nice trick ;)
