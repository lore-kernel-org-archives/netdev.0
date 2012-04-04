From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 1/2] net/bonding: emit address change event in more
 places
Date: Wed, 4 Apr 2012 10:57:03 +0300
Message-ID: <4F7BFECF.2060001@mellanox.com>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com> <1333383430-17456-2-git-send-email-ogerlitz@mellanox.com> <9859.1333492106@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:50301 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755184Ab2DDH5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 03:57:12 -0400
In-Reply-To: <9859.1333492106@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2012 1:28 AM, Jay Vosburgh wrote:
> Is the bond_release_all notifier call actually necessary in your 
> testing? The bond itself is destroyed immediately after 
> bond_release_all returns, so I would expect the neighbours to be 
> deleted then. For that path we probably don't need to zero the mac at 
> all (or compute features, for that matter).

yep, you're right, will remove this extra emitting of event and resend, 
thanks.

Or.
