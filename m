From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 13:14:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029121455.GA11807@infradead.org>
References: <Pine.LNX.4.44.0410290458520.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410290458520.26064-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this uses up vmalloc space and thus is a regression.
