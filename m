From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] key management in wireless
Date: Wed, 22 Nov 2006 09:59:23 +0100
Message-ID: <1164185964.2751.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49815 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161994AbWKVI74
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 03:59:56 -0500
Received: from johannes by sipsolutions.net with local (Exim 4.63)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Gmnqq-0006W7-Bg
	for netdev@vger.kernel.org; Wed, 22 Nov 2006 08:53:04 +0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

As I was reading through lwn I found the article on kernel key
management and wondered wtf I have been smoking that I forgot that I
wanted to use it in wireless :)

Is anyone familiar with with the key management interface and how it
should be used here? It seems that we probably want our own upcall
mechanism for requesting keys and should request them when encryption is
turned on.

johannes
