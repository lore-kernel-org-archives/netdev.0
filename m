From: Luca Maranzano <liuk001@gmail.com>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Fri, 30 Sep 2005 17:59:44 +0200
Message-ID: <68559cef0509300859s38cf42bn@mail.gmail.com>
References: <68559cef05092207022f1f0df4@mail.gmail.com>
	 <20050926032807.GI18357@verge.net.au>
	 <20050926043400.GD5079@us.ibm.com>
	 <20050926080508.GF11027@verge.net.au>
	 <20050926081229.GA23755@verge.net.au>
	 <20050926131104.GA7532@us.ibm.com>
	 <68559cef05092606521cc13f9a@mail.gmail.com>
	 <20050926142109.GD7532@us.ibm.com>
	 <20050928022307.GK18765@verge.net.au>
	 <20050928132639.GA5791@us.ibm.com>
Reply-To: Luca Maranzano <liuk001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Dave Miller <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com, horms@verge.net.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050928132639.GA5791@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First of all thank you all for your precious support! :-)

The two machines on which I discovered the problem are now in
production and I cannot for the moment make tests, but I hope to have
some other hardware to try in the next week.
I'll let you know ASAP.

Thanks,
Luca


>
> Yes, the information in that thread is the same as what Luca said. It's
> a load average problem, not a CPU utilisation problem (those threads are
> sleeping!) If Luca could test the msleep_interruptible() version of the
> patch and it works (like I said, performance should not change, but the
> load average will drop to by 2), then I will ACK the patch for mainline
> acceptance.
>
> Thanks,
> Nish
>
