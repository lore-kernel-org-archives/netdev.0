From: Cedric Jehasse <cedric.jehasse@softathome.com>
Subject: socket option IP_MSFILTER questions and observations
Date: Mon, 26 Mar 2012 17:40:56 +0200
Message-ID: <4F708E08.7040500@softathome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtantr2.softathome.com ([82.138.70.70]:47902 "EHLO
	mtantr2.softathome.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489Ab2CZPsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:48:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by mtantr2.softathome.com (Postfix) with ESMTP id 198C116323
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:41:31 +0200 (CEST)
Received: from mtantr2.softathome.com ([127.0.0.1])
	by localhost (mtantr2.softathome.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ac1pIHy3Pf5b for <netdev@vger.kernel.org>;
	Mon, 26 Mar 2012 17:41:28 +0200 (CEST)
Received: from storentr1.softathome.com (storentr1.softathome.com [192.168.64.166])
	by mtantr2.softathome.com (Postfix) with ESMTP id BBE4616322
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:41:28 +0200 (CEST)
Received: from [192.168.18.124] (unknown [192.168.18.124])
	by storentr1.softathome.com (Postfix) with ESMTPSA id 4168B2C520E8
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:41:28 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to use source specific multicast by setting the IP_MSFILTER 
socket option. I noticed i need to join the group with IP_ADD_MEMBERSHIP 
before setting the source filter. This is not the behavior i expected 
after reading RFC3678.
A potential issue i'm thinking of with this approach: an IGMP report 
could be sent after joining a group but before the filter is set.
Is there a way to prevent this?

Thanks,
Cedric

This message and any attachments herein are confidential, intended solely for the addressees and are SoftAtHome's ownership. Any unauthorized use or dissemination is prohibited. If you are not the intended addressee of this message, please cancel it immediately and inform the sender.
