From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Thu, 08 Jul 2004 19:25:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EDD7F1.6090309@pobox.com>
References: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com> <40E98FB8.4070900@pobox.com> <20040708231131.GA20305@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        David Woodhouse <dwmw2@infradead.org>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040708231131.GA20305@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> Are you sure someone ever tried building this driver modular?  The makefile
> would try to build it into three separate modules, and they'd fail to load
> due to unresolved cross-depencies..


For embedded drivers isn't not uncommon that it's never used as a 
module, so it wouldn't surprise me.
