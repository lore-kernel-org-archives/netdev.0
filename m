From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared with h/w
Date: Thu, 29 Jul 2004 18:50:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729185026.A6033@infradead.org>
References: <Pine.LNX.4.44.0407290726020.21929-100000@westville2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ganesh.venkatesan@intel.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407290726020.21929-100000@westville2.jf.intel.com>; from ganesh.venkatesan@intel.com on Thu, Jul 29, 2004 at 08:29:37AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This sounds rather bogus.  vmallocspace is a scare ressource, don't use it
unless nessecary.
