From: Rick Jones <rick.jones2@hp.com>
Subject: a maze of twisty stats, most different
Date: Wed, 27 Jun 2007 10:20:08 -0700
Message-ID: <46829C48.6080005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:34914 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbXF0RUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 13:20:12 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id 40B2835D03
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 10:20:11 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id KAA12267
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 10:20:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that every driver, when providing support for ethtool -S 
functionality, has considerable lattitude when it comes to the stats 
provided.  Clearly this is very nice for the driver writer(s) as it 
allows them to provide whatever stats they feel are most "natural" for 
their NIC(s) and name them as they see fit.

However :)

 From the standpoint of someone looking from the outside, say someone 
wanting to consume ethtool -S statistics, it seems to be a big jumble.

Might there be a way to bring those two camps together?  Is there 
already, with the same wide availabilty of ethtool, and I've just not 
seen it?

rick jones
