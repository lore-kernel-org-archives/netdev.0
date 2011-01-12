From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Wed, 12 Jan 2011 09:42:13 -0800 (PST)
Message-ID: <247288.34804.qm@web121705.mail.ne1.yahoo.com>
References: <1294853710.3981.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121705.mail.ne1.yahoo.com ([98.138.90.126]:23723 "HELO
	web121705.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753523Ab1ALRmP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 12:42:15 -0500
In-Reply-To: <1294853710.3981.108.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Wed, 12/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Apparently e100 driver uses GFP_ATOMIC allocations in setup
> phase, and your machine doesnt have enough memory.

Thanks. You'd think 64 MB of RAM would be enough... ;-).

Cheers,
Chris


      
