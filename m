From: almaop@poczta.fm
Subject: =?UTF-8?q?iproute2:_2_questions?=
Date: 22 Oct 2009 14:42:21 +0200
Message-ID: <20091022124221.55FCE1A530EE@f12.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: TEXT/plain; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp240.poczta.interia.pl ([217.74.64.240]:9925 "EHLO
	smtp240.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413AbZJVNNH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 09:13:07 -0400
Received: from f12.poczta.interia.pl (f12.poczta.interia.pl [10.217.2.12])
	by smtp240.poczta.interia.pl (INTERIA.PL) with ESMTP id 94C8B106928
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 14:42:21 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by f12.poczta.interia.pl (Postfix) with ESMTP id 55FCE1A530EE
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 14:42:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. There is the known bug so we cant use ipt action with recent  iptables:
tc filter add ...
action ipt -j mark --set-mark 2
does not work.
It does not work with the last iproute2-2.6.29 and with latest git.
Is there some official workaround?
2. Are there plans to release the new iproute2 which fixes this bug?

Krzysiek



----------------------------------------------------------------------
Afera Hazardowa- O co tu chodzi?
Sprawdz >>> http://link.interia.pl/f238e

