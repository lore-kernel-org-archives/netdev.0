From: "David S. Miller" <davem@redhat.com>
Subject: Re: Debian #240812 - tg3 problems with NFS
Date: Thu, 19 Aug 2004 10:29:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819102941.70c94182.davem@redhat.com>
References: <20040819161933.GA27114@lst.de>
	<20040819170619.GA28226@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, stigge@antcom.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040819170619.GA28226@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 19:06:19 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Sorry, should have Cc'ed netdev and the submitter

Maybe it's checksum offload related.  Try:

ethtool -K $(DEVICE_NAME) rx off tx off sg off tso off

Does that make the problem go away?
