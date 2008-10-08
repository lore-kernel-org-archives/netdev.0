From: David Miller <davem@davemloft.net>
Subject: Re: myri10ge: rename main file into myri10ge_main.c
Date: Wed, 08 Oct 2008 16:21:26 -0700 (PDT)
Message-ID: <20081008.162126.191961537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754186AbYJHXVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 19:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not applying this patch nor the one that does the
actual split up.

Single file drivers are so much easier to maintain and
hack on, multi-file drivers are heavily discouraged.

If I want to change some structure member in a multi-file
driver I have go over seperate files instead of doing a
single search and replace operation in a single editing
buffer.

Drivers like e1000, cxgb3 (especially cxgb3!) are such a pain
in the ass to study and make changes to for this reason.  Please
don't add myri10ge to this group.

