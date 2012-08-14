From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [net PATCH v1 1/2] net: netprio: fix files lock and remove
 useless d_path bits
Date: Tue, 14 Aug 2012 03:29:51 +0100
Message-ID: <20120814022951.GF23464@ZenIV.linux.org.uk>
References: <20120814013939.3144.13167.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120814013939.3144.13167.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2012 at 06:39:39PM -0700, John Fastabend wrote:
> -			path = d_path(&file->f_path, tmp, PAGE_SIZE);

What's using tmp after that patch and do you still need to bother
allocating it?
