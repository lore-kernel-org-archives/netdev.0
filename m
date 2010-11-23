From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for November 23 (vmxnet3)
Date: Tue, 23 Nov 2010 09:38:39 -0800
Message-ID: <20101123093839.e618ec2c.randy.dunlap@oracle.com>
References: <20101123140609.2b6503ff.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	pv-drivers@vmware.com
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101123140609.2b6503ff.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Nov 2010 14:06:09 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20101122:


when CONFIG_PCI_MSI is not enabled:

drivers/net/vmxnet3/vmxnet3_ethtool.c:562: error: 'struct vmxnet3_adapter' has no member named 'rss_conf'
drivers/net/vmxnet3/vmxnet3_ethtool.c:578: error: 'struct vmxnet3_adapter' has no member named 'rss_conf'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
