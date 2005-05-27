From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 17:19:13 +0200
Message-ID: <20050527151913.GA15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117206091.6383.73.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117206091.6383.73.camel@localhost.localdomain> 2005-05-27 11:01
> Dave please apply the patch i posted into your tree and then we can
> follow with this other stuff. 
> Actually Thomas, you can probably apply my patch on your side and then
> the other changes to use _NEW() on top of it. If you dont have time i
> could do it tommorow.

Sure, I can come up with a patchset today which will include:
 o the new NLMSG_NEW macro
 o your patch adopted to use the new NLMSG_NEW macro
 o small patch to rename NLMSG_PUT_ANSWER usages into NLMSG_NEW_ANSWER
 o a small fallout from the new neighbour table code which gcc didn't
   warn me about when it should.

OK?
