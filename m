From: David Binderman <dcb314@hotmail.com>
Subject: linux-4.2-rc1/samples/bpf/sockex3_kern.c: bad expression ?
Date: Tue, 7 Jul 2015 11:27:55 +0000
Message-ID: <DUB128-W38D412CB6F86AA3D6084F49C920@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexei Starovoitov <ast@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc1s8.hotmail.com ([157.55.0.207]:58020 "EHLO
	DUB004-OMC1S8.hotmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbbGGLc7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:32:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

[linux-4.2-rc1/samples/bpf/sockex3_kern.c:268]: (style) Expression '(X =
& 0xf0) =3D=3D 0x4' is always false.

Source code is

=A0=A0 if ((verlen & 0xF0) =3D=3D 4)

Maybe

=A0=A0 if ((verlen & 0xF0) =3D=3D 0x40)

Regards

David Binderman


 		 	   		  