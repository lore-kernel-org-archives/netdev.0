From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: linux-4.6/net/kcm/kcmsock.c:1508: bad if test ?
Date: Mon, 16 May 2016 19:40:43 +0100
Message-ID: <CAMzoambRTmpCmM0upiM5PMZtEioSMpw3QB4k--OCvHKmhCnw7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dcb314@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33530 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbcEPSko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:40:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

linux-4.6/net/kcm/kcmsock.c:1508]: (style) Checking if unsigned
variable 'copied' is less than zero.

Source code is

    if (copied < 0) {

but

   size_t copied;

Suggest code rework.


Regards

David Binderman
