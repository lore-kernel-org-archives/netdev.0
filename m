From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 14:14:30 +0100
Message-ID: <20060428131430.GA3288@infradead.org>
References: <200604280003.12743.IvDoorn@gmail.com> <20060427221321.GB22135@infradead.org> <200604281459.24186.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:20139 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030392AbWD1NOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:14:32 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604281459.24186.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 02:59:23PM +0200, Ivo van Doorn wrote:
> I am not sure if that would be a wise idea,
> there is no byte ordering done in rt2500usb except for the EEPROM
> contents which is little endian.
> So when the module is used on a normal x86 platform, there won't be
> any big endian structures or fields.

Well, then you'll need __le* annotation and the le*_to_cpu/cpu_to_le*
instead.  Any new driver should be endian clean.

