From: jamal <hadi@cyberus.ca>
Subject: Re: [RESEND PATCH 2/3] NET: Generic rate estimator
Date: 04 Oct 2004 16:07:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096920421.2156.13.camel@jzny.localdomain>
References: <20041003213124.GG14344@postel.suug.ch>
	 <20041003213954.GI14344@postel.suug.ch>
	 <20041003161436.50293f9a.davem@davemloft.net>
	 <20041003233647.GN14344@postel.suug.ch>
	 <1096852582.1046.378.camel@jzny.localdomain>
	 <20041004125300.GA15898@postel.suug.ch>
	 <1096896256.1072.4.camel@jzny.localdomain>
	 <20041004141532.GB15898@postel.suug.ch>
	 <1096901984.1073.9.camel@jzny.localdomain>
	 <20041004193016.GD15898@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041004193016.GD15898@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-10-04 at 15:30, Thomas Graf wrote:
> Resend of generic rate estimator patch. The HZ%4 check has been removed
> and jiffies calculation has been adapted to avoid carrying on unacuracy.
> Small variance for 250ms interval happens with HZ values of 122 and 50.

Ok, I did some test as well here - and the change you made gives better
results.
Can you also change net/sched/estimator.c to behave the same way?
BTW, anything else that changed since last time other than the timer
adjustment ?

cheers,
jamal
