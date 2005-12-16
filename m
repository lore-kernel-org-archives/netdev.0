From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.15rc5-git4 Forcedeth unstable on Nforce4 - it's not TSO
Date: Fri, 16 Dec 2005 01:29:01 +0100
Message-ID: <20051216002901.GP23384@wotan.suse.de>
References: <DBFABB80F7FD3143A911F9E6CFD477B00BA5DC41@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Content-Disposition: inline
In-Reply-To: <DBFABB80F7FD3143A911F9E6CFD477B00BA5DC41@hqemmail02.nvidia.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I spoke too early when I said earlier that #undef NETIF_F_TSO  fixes it.
Without it it seems to survive longer, but I still get occasional corrupted
MACs. 

-Andi
