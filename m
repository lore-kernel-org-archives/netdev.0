From: Roland Stigge <stigge@antcom.de>
Subject: Re: Debian #240812 - tg3 problems with NFS
Date: Fri, 03 Sep 2004 16:07:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094220426.4139.5.camel@atari.stigge.org>
References: <20040819161933.GA27114@lst.de> <20040819170619.GA28226@lst.de>
	 <20040819102941.70c94182.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, 240812@bugs.debian.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040819102941.70c94182.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-08-19 at 19:29, David S. Miller wrote:
> Maybe it's checksum offload related.  Try:
> 
> ethtool -K $(DEVICE_NAME) rx off tx off sg off tso off
> 
> Does that make the problem go away?

No.
