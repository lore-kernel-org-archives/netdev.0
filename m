From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix TFO regression
Date: Thu, 06 Sep 2012 14:23:31 -0400 (EDT)
Message-ID: <20120906.142331.2164007571017884925.davem@davemloft.net>
References: <20120906045452.GA18181@localhost>
	<1346954833.2484.50.camel@edumazet-glaptop>
	<CADVnQykCJJdM3PfN=_1yyzizao2T6XQJGzC=3uwx5_oazaBicA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fengguang.wu@intel.com, mkl@pengutronix.de,
	hkchu@google.com, ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
To: ncardwell@google.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CADVnQykCJJdM3PfN=_1yyzizao2T6XQJGzC=3uwx5_oazaBicA@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 6 Sep 2012 14:15:38 -0400

> On Thu, Sep 6, 2012 at 2:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Fengguang Wu reported various panics and bisected to commit
>> 8336886f786fdac (tcp: TCP Fast Open Server - support TFO listeners)
>>
>> Fix this by making sure socket is a TCP socket before accessing TFO data
>> structures.
>>
> ...
>>
>> Reported-by: Fengguang Wu <wfg@linux.intel.com>
>> Tested-by: Fengguang Wu <wfg@linux.intel.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: "H.K. Jerry Chu" <hkchu@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks everyone.
