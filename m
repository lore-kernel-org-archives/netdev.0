From: Duan Jiong <djduanjiong@gmail.com>
Subject: How deal with redirect message with no Redirected Header option
Date: Sun, 17 Mar 2013 22:08:14 +0800
Message-ID: <5145CE4E.1000408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:61720 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755720Ab3CQOIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 10:08:22 -0400
Received: by mail-pb0-f42.google.com with SMTP id xb4so5731660pbc.15
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 07:08:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when a redirect message is recived, and if  it has no Redirected Header
option, the kernel will drop it in function ndisc_redirect_rcv(). But i=
t is said
that the Redirected Header option is optional in rfc 4861. Now i=E2=80=99=
m not sure
 whether or not it should be dealt with in function ndisc_redirect_rcv(=
)?

thanks!
