From: Thomas Graf <tgraf@suug.ch>
Subject: Re: register_dev
Date: Mon, 28 Mar 2005 14:23:56 +0200
Message-ID: <20050328122356.GX3086@postel.suug.ch>
References: <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro> 2005-03-28 14:56
> I do a register_netdev inside a _init function of a home made qdisc.
> 2. the module is not loaded and I let tc trigger module loading
> 	tc blocks on modprobe
> How I can resolve this problem?

Port the fix done for classifiers and actions to sch_api.c, see comments
around request_module in cls_api.c
