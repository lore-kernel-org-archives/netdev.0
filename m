From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to
 iov_iter_kvec()
Date: Wed, 15 Apr 2015 11:36:59 +0200
Message-ID: <552E313B.6040302@iogearbox.net>
References: <20150411211742.GJ889@ZenIV.linux.org.uk> <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk> <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com> <20150414163403.GY889@ZenIV.linux.org.uk> <063D6719AE5E284EB5DD2968C1650D6D1CB1DE00@AcuExch.aculab.com> <20150414165920.GB889@ZenIV.linux.org.uk> <063D6719AE5E284EB5DD2968C1650D6D1CB1E86A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Al Viro' <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49829 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbDOJhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 05:37:17 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1E86A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 11:08 AM, David Laight wrote:
...
> Apart from any other code that is using the interface.
> I know you guys don't do anything to help out of tree code, but removing the setfs()
> stuff from the kernel_recvmsg() code would break anything using sctp.

Then that might just be one more incentive to work towards upstreaming
your out-of-tree SCTP bits ... ;)
