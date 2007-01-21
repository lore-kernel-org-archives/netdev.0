From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [RFC] airo.c: Description and function is not the same
Date: Sun, 21 Jan 2007 13:01:26 +0100
Message-ID: <45B35616.6040103@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:45884 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXAUL75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 06:59:57 -0500
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

In the tour of converting local definitions of boolean-type/values, I 
ran into airo.c's description of ex decapsulate():

 *      Returns: BOOLEAN - TRUE if packet should be dropped otherwise FALSE

but returns SUCCESS (defined as 0) and ERROR (defined as -1).

Also, shouldn't those functions be converted to return 'bool' when the 
description say so (happy to do it).

Richard Knutsson

