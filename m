From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Mon, 14 Feb 2005 17:12:24 +0300
Message-ID: <20050214141224.GB15683@yakov.inr.ac.ru>
References: <0528GVO12@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S. Miller" <davem@davemloft.net>, rick.jones2@hp.com,
        shemminger@osdl.org, romieu@fr.zoreil.com, netdev@oss.sgi.com
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Content-Disposition: inline
In-Reply-To: <0528GVO12@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> ethtool -K eth1 tso off
> the result is unchanged on 2.6.9 (14 seconds for 105 MB).
> 
> After,
> ethtool -K eth1 tso off
> the result is also unchanged on 2.6.10-ac11 with no extra TCP patch (325 seconds).

Well, it means the theory was wrong... tso is innocent. To make a new
theory we need a tcpdump of 2.6.10 with disabled tso.


> it's a production server,

I hope we can stay in its normal configuration now. TSO may be kept disabled.

Alexey
