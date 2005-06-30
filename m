From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] updates for [nf|ct]netlink and event API
Date: Thu, 30 Jun 2005 20:02:38 +0200
Message-ID: <20050630180238.GM16076@postel.suug.ch>
References: <20050628071308.GE13239@sunbeam.de.gnumonks.org>
	<42C1747A.3010703@trash.net> <42C2F2DF.7070301@eurodev.net>
	<42C2FC14.80609@trash.net> <42C33E33.7090908@eurodev.net>
	<42C34445.9020709@trash.net>
	<20050630014901.GH16076@postel.suug.ch>
	<42C350A1.1030602@trash.net>
	<20050630120302.GI16076@postel.suug.ch> <42C3F35B.50805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Pablo Neira <pablo@eurodev.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42C3F35B.50805@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <42C3F35B.50805@trash.net> 2005-06-30 15:27
> Thomas Graf wrote:
> > Good point, after all, I think structs have been used too often
> > and we now suffer from backwards compatbility issues. The
> > points likely to be argueable are things like trim responsibility
> > in the error handling, i.e. delegate it down to the function
> > which also created the header or trim on every level. Other than
> > that the whole thing should be pretty straight forward.
> 
> I think for nested attributes error handling should happen on the
> outer level. Just trimming on the inner level would leave a
> half-finished nested attribute.

I can agree with this, the question that remains is: do we want
to trim in functions where no nesting is done at all? i.e. things
like the generic network statistics dumping interface.
