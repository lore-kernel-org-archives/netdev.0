From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Thu, 13 Jan 2011 15:51:15 +0300
Message-ID: <20110113125115.GA28332@ms2.inr.ac.ru>
References: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com> <20110112.184734.38051229.davem@davemloft.net> <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com> <20110113100224.GB30432@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: tgraf@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:55175 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751621Ab1AMMw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 07:52:59 -0500
Content-Disposition: inline
In-Reply-To: <20110113100224.GB30432@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Thu, Jan 13, 2011 at 05:02:24AM -0500, Thomas Graf wrote:
> The reason I didn't change anything was the same as Dave's reply, I
> thought it must have been done on purpose.

The days, when this was written, 0 was interpreted as end of array by sysctl core.
BTW, -1=CTL_ANY also used to be special, that's why NET_PROTO_CONF_ALL=-2 rather than -1.

So, yes, it was done on purpose. And, yes, this purpose is not a legal purpose now.

Alexey
