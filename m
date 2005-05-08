From: Thomas Graf <tgraf@suug.ch>
Subject: Re: SFQ: Reordering?
Date: Sun, 8 May 2005 13:51:00 +0200
Message-ID: <20050508115100.GQ28419@postel.suug.ch>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net> <20050507005851.GK28419@postel.suug.ch> <427C19C3.5030304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427C19C3.5030304@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <427C19C3.5030304@trash.net> 2005-05-07 03:28
> You stated my goal precisely :) I know many people set the interval
> to too low values, but because of the tight limits, it shouldn't be
> very expensive anyways. Table switching OTOH would introduce frequently
> occuring unfairness, and the time to work through a full table is
> a lot longer, especially in the environments where SFQ is used.

I think you are right on this so forget about my thought. Maybe as
an additional input it might be worth mentioning that I have patches
ready to a) make the sfq depth adjustable and b) hash algorithm
selection to a few builtin ones and additional to read theh hash
from tc_classid set by an action. A real world example where this
is useful is for routers primarly doing SNAT without any own local
traffic where hashing algorithm primarly based on the source port
makes a lot more sense.
