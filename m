From: Doug Maxey <dwm@enoyolf.org>
Subject: kernel doc / docbook pdfdocs question
Date: Wed, 30 Sep 2009 14:59:36 -0500
Message-ID: <8223.1254340776@jerryjeff.riw.enoyolf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iggy.enoyolf.org ([24.173.215.189]:47893 "EHLO
	jerryjeff.riw.enoyolf.org" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753811AbZI3VEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 17:04:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Randy,

This may be slightly off topic for this list, but it does involve an
(as yet un-released) network driver. :)

Do you have any insight that could guide me toward a fix for an issue
seen with some header file constructs when trying to generate a pdf
docbook?

In my .tmpl file I do the "process my header file" construct:
...
!Ipath/to/myheader.h
...

In myheader.h an example decl that is giving me fits looks like:

struct foo {
	int bar;
	DECLARE_BITMAP(baz, LENGTH);
	int fotz;
};

It puts the bar and fotz decls in the output, but only outputs a
warning to stderr on the line with DECLARE_BITMAP, nothing about baz
(or DECLARE_BITMAP) is output into the .xml file.

My question is, would it be easier to pre-process the header, say with
gcc -EC via some rule in Documentation/DocBook/Makefile, or to try and
fix whatever gets called by scripts/basic/docbook?

I tried to find what the exact calling sequence was, but am getting
lost in what actually does the xml generation, and therefore how to
fix what is choking on the DECLARE_BITMAP.

Any tips will be very appreciated!

++doug


