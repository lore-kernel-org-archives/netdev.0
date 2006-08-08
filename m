From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/2] crc-itu-t
Date: Tue, 8 Aug 2006 16:21:52 +0200
Message-ID: <200608081621.52132.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:2219 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964914AbWHHOWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 10:22:25 -0400
Received: by nf-out-0910.google.com with SMTP id q29so185796nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 07:22:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

These patches are for wireless-dev
and will add a crc-itu-t implementation to the lib/ directory.
Some drivers are currently using there own version
of this crc routine so there could be usefull to add
this to lib/

The second patch is to make rt2x00 use this crc-itu-t library
and removes its own version of the crc check.

Ivo
