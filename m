From: Christoph Hellwig <hch@lst.de>
Subject: Why is ifenslave.c in the kernel tree?
Date: Sun, 15 Feb 2004 11:02:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040215100258.GA25550@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just looking over the 2.6.3 diffs I see that ifenslave is actively
maintained in Documenation/ of the kernel tree.  Isn't that a _really_
odd place for a userland tool?  We have a policy of not having any
userland tools not used for building in the kernel tree, and especially
none of the distributors will pick it up from there.
