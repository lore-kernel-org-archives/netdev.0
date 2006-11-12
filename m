From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Sat, 11 Nov 2006 20:30:13 -0500
Message-ID: <45567925.3000506@hp.com>
References: <4554A7CD.6040907@hp.com>	<20061110.145507.112290147.davem@davemloft.net>	<45550872.6050900@us.ibm.com> <20061110.152648.88472160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:57989 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1947392AbWKLBaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Nov 2006 20:30:20 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061110.152648.88472160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is a discussion about Brian's SECOND PATCH which needs
> fixups.

Please forget about the second patch, optimizing this code path isn't 
worth it if the -1 trick doesn't work in all cases.

-Brian
