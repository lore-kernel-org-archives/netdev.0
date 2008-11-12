From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Why does IPV6 link local address advertised as /64?
Date: Tue, 11 Nov 2008 20:49:06 -0800
Message-ID: <20081111204906.081d9d57@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47867 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbYKLEtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 23:49:10 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 456C44F4255
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 20:49:11 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8nU9SxQfeAT3 for <netdev@vger.kernel.org>;
	Tue, 11 Nov 2008 20:49:10 -0800 (PST)
Received: from extreme (unknown [96.225.231.79])
	by mail.vyatta.com (Postfix) with ESMTP id 800164F4216
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 20:49:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems to make more sense to have only the actual host (ie /128)
on the link-local address or is there some other purpose to
using a /64?
