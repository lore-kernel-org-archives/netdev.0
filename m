From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/net/tulip/de4x5.c
Date: Thu, 16 Sep 2010 21:53:13 -0700 (PDT)
Message-ID: <20100916.215313.180410528.davem@davemloft.net>
References: <1284586998.6275.94.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kyle@mcmartin.ca, jeffm@suse.com,
	security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284586998.6275.94.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 15 Sep 2010 17:43:18 -0400

> Fixed formatting (tabs and line breaks).
> 
> This was previously reported as a security issue due to leakage of
> uninitialized stack memory.  Jeff Mahoney pointed out that this is
> incorrect since the copied data is from a union (rather than a struct).
> Therefore, this patch is only under consideration for the sake of
> correctness, and is not security relevant. 
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

You need to give something more descriptive than just the name of the
file you're editing in the Subject: line of this commit message.

Otherwise people scanning "shortlog" and similar output won't have
even a general idea of what kind of change your commit is making.

Please formally resubmit this with a proper commit header line.
