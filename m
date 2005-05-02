From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Mon, 2 May 2005 17:06:32 +0200
Message-ID: <20050502150632.GM577@postel.suug.ch>
References: <4273BBAA.6060405@trash.net> <1114882045.8929.123.camel@localhost.localdomain> <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain> <20050430200848.GF577@postel.suug.ch> <1114894202.8929.165.camel@localhost.localdomain> <20050430215550.GH577@postel.suug.ch> <1114900485.8929.171.camel@localhost.localdomain> <20050430235809.GI577@postel.suug.ch> <1115035838.8929.236.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115035838.8929.236.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115035838.8929.236.camel@localhost.localdomain> 2005-05-02 08:10
> I would say that if dummy changes it because of a policy, then thats a
> fair deal. i.e
> 
> filter blah blah \
> action add meta classid global :23 

Absolutely, given it is requested by the user. My main concern are
dependencies on classid invisble to the user.

> I am beginning to think that perhaps classid should stay as a local
> scope metadata and what Patrick suggested maybe the way out. Although i
> have to admit I dont like a generic function to have a parameter that
> only a very small set of users find useful. If we are going to allow a
> structure to be passed back and forth, perhaps it should also carry
> other things (in addition to _result). Need to think a little.

What about if we introduce something like struct tcf_pkt_info as we
have it for ematches? I'm using it intensly to share information
from the classifier to ematches to extend and customize existing
classifier. We could declare tc_classid as being global by definition
and hide the current use in the API? I'd really like to be able to
transfer classification results from one device to another.
