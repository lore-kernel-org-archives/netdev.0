From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Wed, 08 Feb 2006 14:47:12 -0800 (PST)
Message-ID: <20060208.144712.66821895.davem@davemloft.net>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
	<OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, adobriyan@gmail.com,
	carlsonj@workingcode.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: dlstevens@us.ibm.com
In-Reply-To: <OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 8 Feb 2006 14:45:08 -0800

>         Why would sparse complain about this? 0 is a well-defined
> pointer value (the only value guaranteed to be by the language).

Because sparse goes beyond the standards and tries to
catch cases that usually end up being bugs.
