From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] PKT_SCHED: Extended Matches API
Date: Mon, 24 Jan 2005 01:59:50 +0100
Message-ID: <20050124005950.GO23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230132.GC23931@postel.suug.ch> <41F43D6D.30502@trash.net> <20050124004929.GK23931@postel.suug.ch> <41F447CE.6030007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F447CE.6030007@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41F447CE.6030007@trash.net> 2005-01-24 01:56
> Thomas Graf wrote:
> 
> >* Patrick McHardy <41F43D6D.30502@trash.net> 2005-01-24 01:12
> > 
> >
> >>gcc assumes likely for ptr != NULL by default. Is there a reason why a 
> >>match
> >>wouldn't have a match function ?
> >>
> >
> >There is no reason but ematches might get written by unexperienced people
> >forgeting to register it. I know, the if partly hides the failure, it's
> >one of theses case where I have the same arguments for both ways.
> >
> I don't care much, but I guess people forgetting to add a match
> function to an ematch will find other ways to do stupid things :)
> How about catching it in tcf_em_register ?

Sounds like a good plan, will do so. Thanks.
