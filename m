From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] lib, net: make isodigit public and use it
Date: Wed, 10 Apr 2013 14:05:09 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71CA@saturn3.aculab.com>
References: <1365585826-14824-1-git-send-email-andriy.shevchenko@linux.intel.com> <CAOJe8K0H2CbM+05wpM+Gzi4aztq6R4QQ+JwS20uNJz5ck-eSYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jason Baron" <jbaron@redhat.com>, <netdev@vger.kernel.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Denis Kirjanov" <kda@linux-powerpc.org>,
	"Andy Shevchenko" <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53723 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752403Ab3DJNGi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:06:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21308-05 for <netdev@vger.kernel.org>;
 Wed, 10 Apr 2013 14:06:34 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <CAOJe8K0H2CbM+05wpM+Gzi4aztq6R4QQ+JwS20uNJz5ck-eSYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> what about #define isoctal(c) (((c) & ~7) ?

I presume you meant (((c) & ~7) == '0')

Actually the compiler will convert:
    c >= '0' && c <= '7';
into
	(unsigned)(c - '0') <= '7' - '0';
so it makes no significant difference.

Whether adding it to ctype.h is a good idea is a different
problem for the C standards people.

	David
