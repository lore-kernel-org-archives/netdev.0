From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/cxgb4: use remove handler as shutdown handler
Date: Tue, 25 Feb 2014 18:35:53 -0500 (EST)
Message-ID: <20140225.183553.280525429605913122.davem@davemloft.net>
References: <1393272292-11268-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393272292-11268-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 24 Feb 2014 17:04:52 -0300

> Without a shutdown handler, T4 cards behave very badly after a kexec.
> Some firmware calls return errors indicating allocation failures, for
> example. This is probably because thouse resources were not released by
> a BYE message to the firmware, for example.
> 
> Using the remove handler guarantees we will use a well tested path.
> 
> With this patch I applied, I managed to use kexec multiple times and
> probe and iSCSI login worked every time.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
