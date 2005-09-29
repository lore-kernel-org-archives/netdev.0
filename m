From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Thu, 29 Sep 2005 10:00:12 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0509290953080.1309@u.domain.uli>
References: <68559cef05092207022f1f0df4@mail.gmail.com>
 <498263350509230815eb08a73@mail.gmail.com> <20050926032807.GI18357@verge.net.au>
 <20050926043400.GD5079@us.ibm.com> <20050926080508.GF11027@verge.net.au>
 <20050926081229.GA23755@verge.net.au> <20050926131104.GA7532@us.ibm.com>
 <68559cef05092606521cc13f9a@mail.gmail.com> <20050926142109.GD7532@us.ibm.com>
 <20050928022307.GK18765@verge.net.au> <20050928132639.GA5791@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Luca Maranzano <liuk001@gmail.com>, Dave Miller <davem@davemloft.net>,
        Wensong Zhang <wensong@linux-vs.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050928132639.GA5791@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 28 Sep 2005, Nishanth Aravamudan wrote:

> Yes, the information in that thread is the same as what Luca said. It's
> a load average problem, not a CPU utilisation problem (those threads are
> sleeping!) If Luca could test the msleep_interruptible() version of the
> patch and it works (like I said, performance should not change, but the
> load average will drop to by 2), then I will ACK the patch for mainline
> acceptance.

	Agreed. It seems your initial conversion was based on wrong
assumptions, quoting you:

> Description: Use ssleep() instead of schedule_timeout() to guarantee the task
> delays as expected. The first two replacements use TASK_INTERRUPTIBLE but do
> not
> check for signals, so ssleep() should be appropriate.

	As all signals are blocked from daemonize and even explicitly
later it was not necessary to convert to non-interruptible variant.

Regards

--
Julian Anastasov <ja@ssi.bg>
