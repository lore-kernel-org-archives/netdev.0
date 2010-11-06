From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Sat, 6 Nov 2010 13:50:32 -0700
Message-ID: <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
References: <1289074307.3090.100.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46994 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753244Ab0KFUvH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Nov 2010 16:51:07 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oA6KoXYN023185
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Sat, 6 Nov 2010 13:50:34 -0700
Received: by iwn41 with SMTP id 41so2330185iwn.19
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 13:50:33 -0700 (PDT)
In-Reply-To: <1289074307.3090.100.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, November 6, 2010, Dan Rosenberg <drosenberg@vsecurity.com>=
 wrote:
>
> Clearly, in most cases we cannot just remove the field from the /proc
> output, as this would break a number of userspace programs that rely =
on
> consistency. =A0However, I propose that we replace the address with a=
 "0"
> rather than leaking this information.

I really think it would be much better to use the unidentified number
or similar.

Just replacing with zeroes is annoying, and has the potential of
losing actual information.

     Linus
