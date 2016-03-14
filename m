From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Mon, 14 Mar 2016 14:06:42 -0400
Message-ID: <20160314180642.GI5084@oracle.com>
References: <20160311182949.GG3383@oracle.com>
 <20160311110927.5c559421@xeon-e3>
 <20160312024341.GA26486@oracle.com>
 <CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
 <20160312034421.GB26486@oracle.com>
 <CALx6S37gHYMJdz3MzfjKwLHsw0Pmg0SxvQ036sg35AjRackARQ@mail.gmail.com>
 <20160312043952.GC26486@oracle.com>
 <CALx6S37m5s+6h4v1gKiBv2e2p+Ft9Ub4g-YLREWe=A5iuZAseA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41720 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884AbcCNSGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:06:52 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S37m5s+6h4v1gKiBv2e2p+Ft9Ub4g-YLREWe=A5iuZAseA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In any case, to wrap up this thread.

I managed to set this up with sysctl. End result gives me a tunable
per netns (which modparam would not), and thanks to the RDS reconnect
infra, can be done dynamically at any time, not just at startup. 
And it is more compact than a daemon-y solution.

I'll send out the patches later this week after some more cleanup
and testing. 

--Sowmini

However, it would still be nice to know exactly what distribution
issues come out of modparam.
