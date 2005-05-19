From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones
Date: Thu, 19 May 2005 11:52:58 -0700 (PDT)
Message-ID: <20050519.115258.28787892.davem@davemloft.net>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
	<428CB7DC.1050206@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <428CB7DC.1050206@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Nivedita Singhvi <niv@us.ibm.com>
Date: Thu, 19 May 2005 08:59:24 -0700

> While this is generally a cleaner thing to do - it breaks
> what we need - Jon's  patch adds the checksum offload/SG
> unconditionally precisely because we don't want it to be
> an all or nothing - we'd like to utilize offload on those
> devices that do support it..

No, I think Catalin's patch is exactly how this should
be implemented.
