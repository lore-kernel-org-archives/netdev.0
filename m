From: Ldap Tester <ldap.tester@gmail.com>
Subject: severe regression in alx ethernet driver
Date: Mon, 14 Sep 2015 18:47:23 -0300
Message-ID: <CAKM02HMP3WsRYTsm7UVR4tD1jMO5dHrDn6TXg9ARHo-Wqyq2oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35869 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbbINVrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 17:47:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a serious regression in the alx ethernet driver.  The driver
stopped working after upgrading the kernel from 4.0.x to 4.1.x.
Please see https://bugzilla.redhat.com/show_bug.cgi?id=1251434 and
https://bugzilla.kernel.org/show_bug.cgi?id=70761 This regression is
urgent, as I cannot update my kernel to include the latest security
fixes.
