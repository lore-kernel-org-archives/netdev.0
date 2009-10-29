From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 16:14:18 +0100
Message-ID: <66f580dbbf814a9c4b9710f13d8661d8.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Petlund" <apetlund@simula.no>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755247AbZJ2POQ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologise that some of you received this mail more than once. My email
client played a HTML-trick on me.

>> +		icsk->icsk_backoff = 0;
>> +		icsk->icsk_rto = min(((tp->srtt >> 3) + tp->rttvar), TCP_RTO_MAX);
>
> The first part is nowadays done with __tcp_set_rto(tp).
>
> --
>  i.
>

I will address this in the next iteration of the patch.

-AP
