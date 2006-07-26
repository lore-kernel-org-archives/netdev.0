From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 17/24] RT2x00: reorganize allocation/initialization of ieee80211_hw and rt2x00
Date: Wed, 26 Jul 2006 19:05:39 +0200
Message-ID: <200607261905.39332.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030326AbWGZRHm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:42 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:41 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Fix initialization of driver/hardware.
Make a clear seperation between allocation and initialization.
Remove the open() and stop() functions since they have been deprecated
by dscape some time ago.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/17_rt2x00_init.diff
