From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 08:35:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E031286C0@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jon Mason" <jdmason@us.ibm.com>, "Christoph Hellwig" <hch@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>There seems to be 3 ways around this problem.
>1) change the unsigned long fields in ixgb_buffer to unsigned ints
(this
>decreases the size of the struct enough to use kmalloc)

PATCH netdev-2.6 6/10 does this.
