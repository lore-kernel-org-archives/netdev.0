From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared with h/w
Date: Thu, 29 Jul 2004 11:17:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E01F23824@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Christoph Hellwig" <hch@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vmalloc space is less scarce than kmalloc space. Am I right? This patch
trades kmalloc space for vmalloc space.

Ganesh.

-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org] 
Sent: Thursday, July 29, 2004 10:50 AM
To: Venkatesan, Ganesh
Cc: jgarzik@pobox.com; netdev@oss.sgi.com
Subject: Re: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures
not shared with h/w


This sounds rather bogus.  vmallocspace is a scare ressource, don't use
it
unless nessecary.
