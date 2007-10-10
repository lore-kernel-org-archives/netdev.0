From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: authenc compile warnings in current net-2.6.24
Date: Wed, 10 Oct 2007 19:53:53 +0200
Message-ID: <470D11B1.2040207@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:36653 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340AbXJJRzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 13:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

CC [M] crypto/authenc.o
crypto/authenc.c: In function =91crypto_authenc_hash=92:
crypto/authenc.c:88: warning: =91cryptlen=92 may be used uninitialized =
in=20
this function
crypto/authenc.c:87: warning: =91dst=92 may be used uninitialized in th=
is=20
function
crypto/authenc.c: In function =91crypto_authenc_decrypt=92:
crypto/authenc.c:163: warning: =91cryptlen=92 may be used uninitialized=
 in=20
this function
crypto/authenc.c:163: note: =91cryptlen=92 was declared here
crypto/authenc.c:162: warning: =91src=92 may be used uninitialized in t=
his=20
function
crypto/authenc.c:162: note: =91src=92 was declared here

do you already know these warnings?

Oliver
