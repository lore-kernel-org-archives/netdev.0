From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET] Extended matches and basic classifier
Date: Mon, 24 Jan 2005 00:21:47 +0100
Message-ID: <20050123232147.GI23931@postel.suug.ch>
References: <20050123230012.GB23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123230012.GB23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050123230012.GB23931@postel.suug.ch> 2005-01-24 00:00
> 
> This patchset adds the ematch API, the ematches cmp, nbyte, u32, meta,
> and the basic classifier. It doesn't touch any existing code.

Summary about what is planned next regarding ematches:

  The u32 classifier will get transformed to use the u32 ematch instead of
  its own. It will extend the u32 classifer to support logic
  expressions and combines hashing with the classifiction algorithms in
  the ematches. This has been dicussed already about 1-2 weeks ago. It
  will also make the u32 nfmark obsolete.

  The indev match in cls_u32 and cls_fw is going to be removed, it is
  obsoleted by the meta ematch.

  cls_fw is likely to be obsoleted by the meta ematch as well, it still
  has the advantage of the hashing over the ematch though.

  A _very_ simple regular expression ematch.

  Some kind of text search ematch, it is yet unclear wheter to make it
  stateful and maybe use the recent text search code in netfilter or
  make it stateless and simpler.

  The meta ematch will be extended by the addition of more netfilter,
  socket, and routing attributes.

  A "state" ematch allowing to limit classification on the first few
  packets of a connection and mark all further packets the same.
