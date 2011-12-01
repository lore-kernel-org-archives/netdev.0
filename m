From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Thu, 1 Dec 2011 08:24:36 -0800
Message-ID: <20111201082436.20f21e52@nehalam.linuxnetplumber.net>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
	<1322691627-20551-2-git-send-email-hagen@jauu.net>
	<1322710225.2577.1.camel@edumazet-laptop>
	<cfd2e2c26063da002d8afe76991ff0c1@localhost>
	<1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<61abe6ff1aa870d1b885ce88814920d4@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54247 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263Ab1LAQYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:24:39 -0500
In-Reply-To: <61abe6ff1aa870d1b885ce88814920d4@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One idea to do small delays at higher speed is to insert dummy pad frames
into the device. It would mean generating garbage, but would allow for
highly accurate fine grain delay.
