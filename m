From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24 0/5] TCP: Cleanups & SACK block validation
Date: Mon, 20 Aug 2007 16:16:28 +0300
Message-ID: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34469 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522AbXHTNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here are couple of patches to net-2.6.24. The first three are trivial
cleanups. The idea to the last two comes from tcp-2.6 but the validator
has been heavily modified (and hopefully improved in the process :-)).
I'm not sure though if checking for the undo_marker boundary crossing
case is a bit over-engineering (inherited from the original version
which already checked for that case). In addition, better names could
be invented for MIBs, suggestions?

--
 i.


