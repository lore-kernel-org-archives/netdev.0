From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 0/2]: TCP MTUprobe fixes
Date: Wed, 21 Nov 2007 18:01:26 +0200
Message-ID: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42476 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbXKUQBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 11:01:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,          
   
Here are two other things in MTU probe code that caught my
attention while attempting to figure out the sk_send_head
usage there (sent patch to that earlier). The latter here is
not strictly speaking a fix but the original code has striking
complexity to perform a query which can be reduced to a simple
operation, thus I included it here as well. If these seem fine
to you as well, inclusion net-2.6 would be nice. Only compile
tested.
   
-- 
 i.


