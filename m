From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.25 0/4] [NET]: Bloat, bloat and more bloat
Date: Wed, 9 Jan 2008 13:35:52 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801091328240.31652@kivilampi-30.cs.helsinki.fi>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080105144608.GD12379@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1661905114-1199878552=:31652"
Cc: Netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44999 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbYAILfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 06:35:55 -0500
In-Reply-To: <20080105144608.GD12379@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1661905114-1199878552=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 5 Jan 2008, Arnaldo Carvalho de Melo wrote:

> Em Sat, Jan 05, 2008 at 03:39:04PM +0200, Ilpo Järvinen escreveu:
> > Hi Dave,
> > 
> > After Arnaldo got codiff's inline instrumentation bugs fixed
> > (thanks! :-)), I got my .c-inline-bloat-o-meter to power up
> > reliably after some tweaking and bug fixing on my behalf...
> > It shows some very high readings every now and then in the
> > code under net/.
> 
> Thank you for the reports and for showing how these tools can be put to
> good use! 
> 
> If you have any further suggestions on how to make codiff and the
> dwarves to be of more help or find any other bug, please let me know.

It could use a bit less memory because my header inline checking attempt 
on a machine with 2G+2G ends up like this:

$ codiff vmlinux.o.base vmlinux.o
libclasses: out of memory(inline_expansion__new)
$ ls -al vmlinux.o{,.base}
-rw-r----- 1 ijjarvin tkol 633132586 Jan  9 13:11 vmlinux.o
-rw-r----- 1 ijjarvin tkol 633132572 Jan  9 00:58 vmlinux.o.base
$

Considering that's only 0.6G+0.6G I've a problem in understanding why 
codiff's number crunching eats up so much memory.

I just hope there isn't any O(n^2) or worse algos in it either once
the memory consumption gets resolved. :-)


-- 
 i.
---696243703-1661905114-1199878552=:31652--
