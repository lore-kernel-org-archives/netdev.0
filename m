From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP NewReno and single retransmit
Date: Tue, 4 Nov 2014 09:38:47 -0500
Message-ID: <CADVnQy=zk3hWOzG3Oo3kj6ve382SBbaVhQmhK9Eky1DCnbES-A@mail.gmail.com>
References: <544E93BD.50202@redhat.com>
	<CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
	<54521FD6.70403@redhat.com>
	<CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>
	<5457AF6D.6010105@redhat.com>
	<CADVnQykXpA_A87+bFOCdbb-QLTRf-5TEgspCzE-STO49N+6waw@mail.gmail.com>
	<5457F52F.8060002@redhat.com>
	<CADVnQykePToQ-MatwFV=o7iYw_1T7L_jg_3NtaXRueyMA=GAuw@mail.gmail.com>
	<CAK6E8=cgkznkAWTps7aA+txuETpZ2RNiU3rbQf9WxLjawhgNog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:63820 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbaKDOis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 09:38:48 -0500
Received: by mail-qg0-f48.google.com with SMTP id q108so10496536qgd.21
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 06:38:47 -0800 (PST)
In-Reply-To: <CAK6E8=cgkznkAWTps7aA+txuETpZ2RNiU3rbQf9WxLjawhgNog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 2:59 AM, Yuchung Cheng <ycheng@google.com> wrote:
> Thanks for checking. So my suggested fix of removing the hold state is
> the "less careful variant" that RFC does not recommend. I would rather
> have the proposed 2-liner fix than implementing the section 6
> heuristics to detect spurious retransmit. It's not worth the effort.
> Everyone should use SACK.

Agreed. The simple 2-liner seems like the simplest and lowest-risk
fix. And given that >95% of public Internet flows and an even higher
proportion of datacenter flows use SACK, it's not worth spending time
optimizing NewReno.

neal
