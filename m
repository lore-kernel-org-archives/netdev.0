From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Wed, 2 Feb 2005 16:55:43 +0100
Message-ID: <20050202155543.GR31837@postel.suug.ch>
References: <1107189625.1076.77.camel@jzny.localdomain> <20050131181553.GG31837@postel.suug.ch> <1107202715.1075.559.camel@jzny.localdomain> <20050131225328.GI31837@postel.suug.ch> <1107259361.1095.584.camel@jzny.localdomain> <20050201125147.GK31837@postel.suug.ch> <1107263612.1095.598.camel@jzny.localdomain> <20050201224436.GO31837@postel.suug.ch> <1107354293.1105.85.camel@jzny.localdomain> <20050202154041.GQ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050202154041.GQ31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>   tc_index: May contain a dscp value if dsmark is told to fetch the dscp
>             field, the minor part of priority if dsmark is told to map
>             priority values via handle values, or the minor part of the
>             classid in a classifier result via ingress classification or
>             a classifier attached to a dsmark. cls_tcindex, gred, and
>             meta ematch use it as input value.

Assuming we use tc_index to provide the hash...

- we don't need to worry about any definitions. tc_index already stands for
  some kind of index grouping together various packets.
- we can directly use sfq to do fair queueing on dscp values and skb
  priority including specialized map with a underlying dsmark or cls_tcindex.
