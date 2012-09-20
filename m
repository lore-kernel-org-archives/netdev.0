From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: add nameserver IPs to kernel-parameter ip=
Date: Thu, 20 Sep 2012 17:37:19 -0400 (EDT)
Message-ID: <20120920.173719.1238894522809866676.davem@davemloft.net>
References: <1348176485.3858.92.camel@mars>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, kuznet@ms2.inr.ac.ru, j.weitzel@phytec.de,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hjk@hansjkoch.de, daniel@zonque.org
To: chf.fritz@googlemail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1348176485.3858.92.camel@mars>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Thu, 20 Sep 2012 23:28:05 +0200

> +			pr_info("     nameserver%u=%pI4",
> +							i, &ic_nameservers[i]);

Why don't you just tab that second line out to planet Mars while
you're at it?

Please format this correctly, the goal is not to use a million
TAB characters.  Rather, the goal is to get the text starting
on the second line of a function call to line up with the
first column after the openning parenthesis on the previous line.

What you're doing there looks awful, so you'll need to fix this
up before this patch will be considered seriously.

Thanks.
