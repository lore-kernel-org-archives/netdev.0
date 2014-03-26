From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 0/2] bridge: Fix forwarding of 8021AD frames
Date: Wed, 26 Mar 2014 12:00:25 -0400
Message-ID: <1395849627-15711-2-git-send-email-vyasevic@redhat.com>
References: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779AbaCZQBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 12:01:01 -0400
In-Reply-To: <1395849627-15711-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge has its own way to deterine if the packet is forwardable and it doesn't
support 8021ad tags correctly.  Instead just allow bridge to use an
existing is_skb_forwardable() function.

-vlad
