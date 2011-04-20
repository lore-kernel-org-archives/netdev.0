From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 01:12:38 -0700 (PDT)
Message-ID: <20110420.011238.193725676.davem@davemloft.net>
References: <4DA71876.803@redhat.com>
	<1302797147.3248.32.camel@edumazet-laptop>
	<4DAE8E47.7040409@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hagen@jauu.net, netdev@vger.kernel.org,
	acme@infradead.org, bhutchings@solarflare.com
To: avi@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750728Ab1DTINO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:13:14 -0400
In-Reply-To: <4DAE8E47.7040409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avi Kivity <avi@redhat.com>
Date: Wed, 20 Apr 2011 10:41:59 +0300

> To avoid getting into an infinite loop (btw, does you jit avoid
> infinite loops in the generated code?) I'll restate what I think are
> an external jit's advantages and then stop harping on the subject:

Only forward branching is allowed in BPF code.
