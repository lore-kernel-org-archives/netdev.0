From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 13/25] ipvs: remove check for IP_VS_CONN_F_SYNC from
 ip_vs_bind_dest
Date: Tue, 8 May 2012 04:15:15 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1205080414470.19642@frira.vanv.qr>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org> <1336436539-5880-14-git-send-email-pablo@netfilter.org> <20120507.213607.2054696052002528963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120507.213607.2054696052002528963.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 2012-05-08 03:36, David Miller wrote:

>From: pablo@netfilter.org
>Date: Tue,  8 May 2012 02:22:07 +0200
>
>> +		/* It is a normal connection, so modify the counters
>> +		 * according to the flags, later the protocol can
>> +		 * update them on state change */
>
>Rather:
>
>		/* It is a normal connection, so modify the counters
>		 * according to the flags, later the protocol can
>		 * update them on state change
>		 */

Well, CodingStyle even says

>		/*
>		 * It is a normal connection, so modify the counters
>		 * according to the flags, later the protocol can
>		 * update them on state change.
>		 */
