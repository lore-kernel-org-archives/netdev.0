From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFR] gianfar ethernet driver
Date: Fri, 9 Jul 2004 00:35:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708233537.GA20763@infradead.org>
References: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com> <40E98FB8.4070900@pobox.com> <20040708231131.GA20305@infradead.org> <40EDD7F1.6090309@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        David Woodhouse <dwmw2@infradead.org>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40EDD7F1.6090309@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 07:25:37PM -0400, Jeff Garzik wrote:
> Christoph Hellwig wrote:
> >Are you sure someone ever tried building this driver modular?  The 
> >makefile
> >would try to build it into three separate modules, and they'd fail to load
> >due to unresolved cross-depencies..
> 
> 
> For embedded drivers isn't not uncommon that it's never used as a 
> module, so it wouldn't surprise me.

then it shouldn't be declare tristate at least.  But given that modularizig
a netdriver is trivial not doing so counts as a bug to me.
