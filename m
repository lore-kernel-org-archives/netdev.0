From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Fri, 26 Nov 2010 03:20:31 -0800 (PST)
Message-ID: <174335.2288.qm@web53702.mail.re2.yahoo.com>
References: <20101126110726.GA5648@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53702.mail.re2.yahoo.com ([206.190.37.23]:37376 "HELO
	web53702.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754669Ab0KZLUc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 06:20:32 -0500
In-Reply-To: <20101126110726.GA5648@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Fri, 26/11/10, Evgeniy Polyakov <zbr@ioremap.net> wrote:

> Frankly I did not find how those optimizations made a bug
> as well as
> what is this bug about from given description, but I'm glad
> it is resolved now :)
> 

I'm not sure of what all went into the "optimization" patch, but the bug is not due to the optimization per-se. As my original post says, it is due to the 'bsockets' and 'num_owners' not being incremented inside __inet_inherit_port(), where it should have been, as __inet_put_port() decrements them on port release, which causes the imbalance.

Thanks,
Tomar


      
