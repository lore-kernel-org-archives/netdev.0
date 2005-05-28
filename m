From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] [NETLINK] Correctly set NLM_F_MULTI without
	checking the pid
Date: Fri, 27 May 2005 21:06:55 -0400
Message-ID: <1117242415.6251.10.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
	 <1117202331.6383.39.camel@localhost.localdomain>
	 <20050527141320.GQ15391@postel.suug.ch>
	 <1117206091.6383.73.camel@localhost.localdomain>
	 <20050527151913.GA15391@postel.suug.ch>
	 <1117209466.6383.106.camel@localhost.localdomain>
	 <20050527165935.GC15391@postel.suug.ch>
	 <20050527170135.GE15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527170135.GE15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, looks good. Dave please apply this one instead of the one i posted
this morning  - it incorporates the name change as well. 
Incase its not clear - 1/2 in this patch set is also fine.

cheers,
jamal

On Fri, 2005-27-05 at 19:01 +0200, Thomas Graf wrote:
> This patch rectifies some rtnetlink message builders that derive the
> flags from the pid. It is now explicit like the other cases
> which get it right. Also fixes half a dozen dumpers which did not
> set NLM_F_MULTI at all.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
