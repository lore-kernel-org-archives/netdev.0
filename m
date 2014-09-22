From: Christoph Hellwig <hch@infradead.org>
Subject: getting rid of ->splice_write?
Date: Mon, 22 Sep 2014 10:30:53 -0700
Message-ID: <20140922173053.GA13109@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently only /dev/null, fusedev and the socket code have a
splice_write implementation that isn't iter_file_splice_write, and
it seems like these three could easily be switched over if they
implemented a ->write_iter.

Similarly it seems to be like we could kill ->splice_read by
implementing an equivalent iteration over ->read_iter.
