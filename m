From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Fri, 31 Dec 2004 19:19:33 +0100
Message-ID: <20041231181933.GQ32419@postel.suug.ch>
References: <1104330054.1089.329.camel@jzny.localdomain> <20041229150140.GJ32419@postel.suug.ch> <1104335620.1025.22.camel@jzny.localdomain> <20041230174313.GB32419@postel.suug.ch> <1104469111.1049.219.camel@jzny.localdomain> <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20041231181153.GP32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20041231181153.GP32419@postel.suug.ch> 2004-12-31 19:11
>  T=1 generic selector header
>  T=2 classifier specific selector header (u32 hashsing stuff goes here)
>  T=3 ematch 1
>  T=N ematch N

Of course this should have been:

T=N ematch N-2
