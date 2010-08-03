From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 19:05:39 +0200
Message-ID: <4C584C63.8010607@trash.net>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: "Gabor Z. Papp" <gzp@papp.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57386 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399Ab0HCRFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 13:05:44 -0400
In-Reply-To: <x6bp9jy7sj@gzp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 03.08.2010 18:34, schrieb Gabor Z. Papp:
> * Patrick McHardy <kaber@trash.net>:
> 
> |     iptables version 1.4.9
> 
> ...
> libiptc/.libs/libip4tc.a extensions/libext4.a ./.libs/libxtables.a -lm
> collect2: ld terminated with signal 11 [Segmentation fault]
> extensions/libext4.a(initext4.o): In function `init_extensions':
> /home/gzp/src/iptables-1.4.9/extensions/initext4.c:138: undefined reference to `libxt_TEE_init'
> make[2]: *** [iptables-multi] Error 1

Did you use a git checkout/patch against 1.4.8 or the tar.bz2?
In case its the former, try running make clean, sh autogen.sh and
sh configure again before the build.
