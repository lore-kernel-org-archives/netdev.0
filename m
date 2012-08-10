From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Date: Fri, 10 Aug 2012 19:26:28 +0100
Message-ID: <20120810192628.79a34d28@pyramind.ukuu.org.uk>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
	<50254FA6.3060806@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Trond.Myklebust@netapp.com, davem@davemloft.net,
	linux-nfs@vger.kernel.org, eric.dumazet@gmail.com,
	xemul@parallels.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bfields@fieldses.org,
	viro@zeniv.linux.org.uk, tim.c.chen@linux.intel.com,
	devel@openvz.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50254FA6.3060806@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On that whole subject...
> 
> Do we need a Unix domain socket equivalent to openat()?

I don't think so. The name is just a file system indexing trick, it's not
really the socket proper. It's little more than "ascii string with
permissions attached" - indeed we also support an abstract name space
which for a lot of uses is actually more convenient.

AF_UNIX between roots raises some interesting semantic questions when you
begin passing file descriptors down them as well.

Alan
