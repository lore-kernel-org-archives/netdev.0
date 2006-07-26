From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/24] RT2x00
Date: Wed, 26 Jul 2006 19:04:16 +0200
Message-ID: <200607261904.16781.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751705AbWGZRHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 13:07:20 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:19 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here is a new series of patches to bring rt2x00 in wireless-dev
up to date again.

I am holding back 2 patches, which will be send later this week,
but they are changes not only to rt2x00, so there is a chance those
patches will be rejected at first.

Anyway, here are the patches for rt2x00 only. ;)

Some of the patches are quite large, and have been placed
on an external server. Links can be found in the patch mail.

Some of the main changes:
- Code style fix
- suspend/resume fix (Yes, this time it is actually working)
- Device initialization cleanup
- Ethtool support
- register initialization fixes
- Reduce code duplication

After these patches the status of rt2x00 is as follows:

Master mode works, a connection can be established that lasts for a few hours.
Data transfer speed match 1Mbit/s, so there is something not right yet.

Monitor mode seems to work as expected, except for USB devices, which seem
to have problems with RX.

Managed mode seems to be able to start associations, but the connection is not 
lasting and the longest association time seems to be 20 minutes.

Ivo
