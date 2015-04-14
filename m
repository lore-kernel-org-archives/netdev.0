From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to
 iov_iter_kvec()
Date: Tue, 14 Apr 2015 16:36:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1DE00@AcuExch.aculab.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com>
 <20150414163403.GY889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:56024 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbbDNQic convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:38:32 -0400
In-Reply-To: <20150414163403.GY889@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro 
> Sent: 14 April 2015 17:34
> On Tue, Apr 14, 2015 at 04:21:02PM +0000, David Laight wrote:
> 
> > Massive NAK.
> > This breaks any code that is using msg_control to set SCTP parameters
> > when sending data.
> 
> 	Huh?  ->sendmsg() expects ->msg_control already in kernel space;
> it's ->recvmsg() that plays silly buggers with userland pointers there.

I read your commit message as implying that you hadn't found any
users of kernel_sendmsg() that used msg_control.
Not that the data was always read from kernel space.

	David
