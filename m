From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Mon, 8 Nov 2010 10:04:48 +0200
Message-ID: <201011081004.48382.remi.denis-courmont@nokia.com>
References: <1289147492.3090.137.camel@Dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>,
	"stable@kernel.org" <stable@kernel.org>
To: ext Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:61435 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753958Ab0KHIGz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 03:06:55 -0500
In-Reply-To: <1289147492.3090.137.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 07 November 2010 18:31:32 ext Dan Rosenberg, you wrote:
> This patch series resolves the leakage of kernel heap addresses to
> userspace via network protocol /proc interfaces and public error
> messages.  Revealing this information is a bad idea from a security
> perspective for a number of reasons, the most obvious of which is it
> provides unprivileged users a mechanism by which to create a structur=
e
> in the kernel heap containing function pointers, obtain the address o=
f
> that structure, and overwrite those function pointers by leveraging
> other vulnerabilities.  It is my hope that by eliminating this
> information leakage, in conjunction with making statically-declared
> function pointer tables read-only (to be done in a separate patch
> series), we can at least add a small hurdle for the exploitation of a
> subset of kernel vulnerabilities.

Seems like this patch series is incomplete to me as far as /proc/net is=
=20
concerned.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
