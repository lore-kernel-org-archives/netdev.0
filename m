From: Michael Tokarev <mjt@tls.msk.ru>
Subject: tun new missing ioctl32
Date: Fri, 30 Jan 2009 02:43:53 +0300
Message-ID: <49823F39.8080204@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:51954 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbZA2Xnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 18:43:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just saw in dmesg:

ioctl32(kvm:4408): Unknown cmd fd(9) cmd(800454cf){t:'T';sz:4} arg(ffc668e4) on /dev/net/tun

I guess it's the recent stuff, TUNSETOFFLOAD perhaps, which is
missing compat_ioctl entry...  Who knows this area, care to fix
it please? :)

(Yes, 32bit userspace on 64bit kernel)

Thanks!

/mjt
