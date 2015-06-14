From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Subject: displayed name changed in ip link show for bridge- and other interfaces
Date: Sun, 14 Jun 2015 12:00:18 +0200
Message-ID: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:58291 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751064AbbFNKHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 06:07:20 -0400
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id AB83A601EE
	for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 12:00:20 +0200 (CEST)
Received: from ikr.uni-stuttgart.de (pc041 [10.21.21.41])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id 9214060078
	for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 12:00:20 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

between Linux 4.0.5 and 4.1-rc7 the name as shown by "ip link show"
of bridge interfaces (and at least the dummy interface) changed from 
(i.e.) br1 to br1@NONE.

This breaks (at least for me :-) userspace (ip link show parsing
scripts). It is easy to solve, so not a big problem. I am using
Ubuntu 14.04.

Is this user visible change intended?

Thank you and best regards

Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart, Germany
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
