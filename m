From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:09:50 -0700 (PDT)
Message-ID: <20050517.120950.74749758.davem@davemloft.net>
References: <20050517.104947.112621738.davem@davemloft.net>
	<m1zmut7l5q.fsf@muc.de>
	<200505171457.38719.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jheffner@psc.edu
In-Reply-To: <200505171457.38719.jheffner@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 May 2005 14:57:38 -0400

> It would be better still to have a per-route packet reassembly timeout in 
> milliseconds.

I agree.  And if we can setup the infrastructure such that the
drivers can indicate the speed of the link they are communicating
on, then we can set sane default values on the automatically
created subnet routes.

These would need to be refreshed when link state changes, but
we have the mechanics for that kind of device event stuff
already.
