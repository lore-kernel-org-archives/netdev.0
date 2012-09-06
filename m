From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: fix TFO regression
Date: Thu, 6 Sep 2012 14:15:38 -0400
Message-ID: <CADVnQykCJJdM3PfN=_1yyzizao2T6XQJGzC=3uwx5_oazaBicA@mail.gmail.com>
References: <20120904140411.GB15068@localhost>
	<5046361C.5070602@pengutronix.de>
	<87mx15zfze.fsf@xmission.com>
	<20120905145508.GA9450@localhost>
	<50476931.20100@pengutronix.de>
	<1346859046.13121.144.camel@edumazet-glaptop>
	<1346859645.13121.146.camel@edumazet-glaptop>
	<1346864220.13121.157.camel@edumazet-glaptop>
	<20120906045452.GA18181@localhost>
	<1346954833.2484.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1346954833.2484.50.camel@edumazet-glaptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 6, 2012 at 2:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Fengguang Wu reported various panics and bisected to commit
> 8336886f786fdac (tcp: TCP Fast Open Server - support TFO listeners)
>
> Fix this by making sure socket is a TCP socket before accessing TFO data
> structures.
>
...
>
> Reported-by: Fengguang Wu <wfg@linux.intel.com>
> Tested-by: Fengguang Wu <wfg@linux.intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: "H.K. Jerry Chu" <hkchu@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
