From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 14:58:47 -0800
Message-ID: <41F18927.5020607@hp.com>
References: <41F1516D.5010101@hp.com>	<200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com>	<20050121141820.7d59a2d1.davem@davemloft.net> <41F186A8.9030805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41F186A8.9030805@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> That's not to say that we still won't have incentive to set
> tcp_tso_win_divisor (shouldn't that really be tcp_tso_cwnd_divisor?) to 1 :)

Speaking of divisor values... is zero (0) supposed to be a legal value?  The 
sysctl seems to allow it but it does seem to behave a triffle strangely.  The 
initial TSO size appeared to be 2MSS.

It might be rather interesting if a value of zero were to have the effect of 
ignoring initial cwnd entirely :)  It wouldn't be "legal" in the RFC sense, but 
I suspect it would make for some interesting experimental opportunities.  Rather 
far down on the list though.

rick jones
