From: "Aravind Ceyardass" <aravind1001@speedpost.net>
Subject: Re: Re: pci-skeleton duplex check
Date: Mon, 16 Dec 2002 14:55:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021216185513.43F023D56F@server2.fastmail.fm>
References: <200212141428.TAA32351@WS0005.indiatimes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: aravind1001@speedpost.net
Return-path: <netdev-bounce@oss.sgi.com>
Content-Disposition: inline
To: "arun4linux" <arun4linux@indiatimes.com>,
   "Michael Richardson" <mcr@sandelman.ottawa.on.ca>, netdev@oss.sgi.com,
   "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
In-Reply-To: <200212141428.TAA32351@WS0005.indiatimes.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

A good scheme for numbering kernels or software components in general is
as follows

For stable releases. (x.even.y=major.minor.patch)

increment patch for any bug fixes.
increment minor for any enhancements or new interfaces.
increment major for interface changes or interface deletions.(dangerous
or poor design)

We should increment major even if interface remains same but behaviour
has changed.(again may be poor design)

For development releases we can't follow the above scheme, because the
interfaces are in a flux and we may end up
in version 589.201.700 from 2.4.20. So, we decide to increment patch
number for all changes and deletions.

Hope it helps!

Regards

Aravind


-- 
http://fastmail.fm - IMAP accessible web-mail
