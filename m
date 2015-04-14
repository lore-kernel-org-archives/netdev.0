From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Tue, 14 Apr 2015 16:25:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1DDB2@AcuExch.aculab.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:62656 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbbDNQ1U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:27:20 -0400
In-Reply-To: <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> Sent: 11 April 2015 22:18
> it's equal to iov_iter_count(&msg->msg_iter) in all cases

I don't know whether this is guaranteed for iov[] that come from
userspace.

In any case iov_iter_count() is non-trivial and you don't
really want to call it when unnecessary.

	David
