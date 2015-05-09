From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net/rds: RDS-TCP robustness fixes
Date: Sat, 09 May 2015 16:03:52 -0400 (EDT)
Message-ID: <20150509.160352.619521748833984114.davem@davemloft.net>
References: <cover.1430843646.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1430843646.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue,  5 May 2015 15:20:50 -0400

> 
> This patch-set contains bug fixes for state-recovery at the RDS 
> layer when the underlying transport is TCP and the TCP state at one 
> of the endpoints is reset
> 
> V2 changes: DaveM comments to reduce memory footprint, follow 
>             NFS/RPC model where possible. Added test-case #3
> 
> Without the changes in this set, when one of the endpoints is reset,
> the existing code does not correctly clean up RDS socket state for stale
> connections, resulting in some unstable, timing-dependant behavior on
> the wire, including an infinite exchange of 3WHs back-and-forth, and a
> resulting potential to never converge RDS state. 
 ...

Yeah this looks a lot better, series applied, thanks.
