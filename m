From: wp1081184-tech <tech@domaigne.com>
Subject: CDC NCM: question regarding =?UTF-8?Q?dev-=3Erx=5Furb=5Fsize?=
Date: Sat, 26 May 2012 14:39:40 +0200
Message-ID: <5e3d8e86e9e6cf283c67e54c86a8939b-EhVcX1dARApbRx0VCw03AF9BdAJSS1xcXV9EAF01UUhGV1kPQV5/H1ZRMl5cQk0CXF9QSFg=-webmailer2@server02.webmailer.hosteurope.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server01.mc0.hosteurope.de ([92.51.170.72]:44356 "EHLO
	server01.mc0.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750856Ab2EZMuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2012 08:50:10 -0400
Received: from server02.webmailer.hosteurope.de ([10.9.0.181]);
	by mailout.hosteurope.de (server01.mc0.hosteurope.de) running EXperimental Internet Mailer with esmtps (TLSv1:AES256-SHA:256)
	id 1SYGHV-0001Is-1T
	for netdev@vger.kernel.org; Sat, 26 May 2012 14:39:41 +0200
Received: from nobody by server02.webmailer.hosteurope.de with local (Exim 4.72)
	(envelope-from <tech@domaigne.com>)
	id 1SYGHU-00036h-Vy
	for netdev@vger.kernel.org; Sat, 26 May 2012 14:39:40 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

 I am facing a strange performance problem with a device. I am using th=
e
 "14-Mar-2012" driver found in linux 3.4.

 The device announces a dwNtbInMaxSize of 32 kB, hence causing=20
 ctx->rx_max to be
 32kB and as a result dev->rx_urb_size too, since:
 dev->rx_urb_size =3D ctx->rx_max; // in cdc_ncm_bind()

 The performance (transfer rate) are however miserable. If I however se=
t=20
 manually
 the dev->rx_urb_size to 16kB instead of 32kB, I get very good=20
 performance.

 So my questions are:

 1) what is this rx_urb_size setting for? Where is it used (in usbnet?)=
=2E=20
 Could
 you detail?

 2) Why changing from 32kB to 16kB could cause such dramatic performanc=
e
 improvement?

 If you need additional info, let me know.

 TIA, Lo=C3=AFc
