From: Tim Hockin <thockin@hockin.org>
Subject: Re: [RFC] ethtool semantics
Date: Mon, 14 Jun 2004 10:01:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614170138.GA32594@hockin.org>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com> <20040608210809.GA10542@k3.hellgate.ch> <40C77C70.5070409@tmr.com> <20040609213850.GA17243@k3.hellgate.ch> <20040609151246.1c28c4d9.davem@redhat.com> <Pine.LNX.4.58.0406141458270.16762@fcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Herbert <marc.herbert@free.fr>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0406141458270.16762@fcat>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 14, 2004 at 03:11:15PM +0200, Marc Herbert wrote:
> > That is absolutely the correct thing to do, module parameters for
> > link settings are %100 deprecated, people need to use ethtool for
> > everything.
> 
> This is precisely the reason why I am concerned about having "rich"
> ethtool semantics. A unified, standard interface is great,... as long
> it does not leave behind some features, like setting the advertised
> values in autoneg. As a user of these features, I hope driver
> developers will NOT remove those module_param features that cannot
> migrated to ethtool.

So propose a sane semantic that handles all three cases:
* autoneg on
* autoneg off
* autoneg on but limited
