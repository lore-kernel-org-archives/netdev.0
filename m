From: Christian Borntraeger <linux-kernel@borntraeger.net>
Subject: Re: [Patch 12/16 2.5] ixgb: replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 15 Oct 2004 18:46:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410151846.42479.linux-kernel@borntraeger.net>
References: <Pine.LNX.4.44.0410150638490.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150638490.31227-100000@isotope.jf.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> - rxdr->buffer_info = kmalloc(size, GFP_KERNEL);
[...]
> + rxdr->buffer_info = vmalloc(size);

What is the rationale for this change?

If I recall correctly, Linus opposes the use of vmalloc if there is no real 
need.

cheers

Christian
