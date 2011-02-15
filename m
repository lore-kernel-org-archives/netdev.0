From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Process for subsystem maintainers to get Hyper-V code out of
 staging.
Date: Tue, 15 Feb 2011 10:33:45 +0000
Message-ID: <20110215103345.0b121493@lxorguk.ukuu.org.uk>
References: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"Jame.Bottomley@HansenPartnership.com"
	<Jame.Bottomley@HansenPartnership.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Hashir Abdi <habdi@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"gregkh@suse.de" <gregkh@suse.de>
To: Hank Janssen <hjanssen@microsoft.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <8AFC7968D54FB448A30D8F38F259C56233F95737@TK5EX14MBXC114.redmond.corp.microsoft.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	1. Most important thing of course, did we contact the correct subsystem 
> 	    maintainers?
> 		i. IDE/Blkvsc		David Miller

Libata - Jeff Garzik & linux-ide@vger.kernel.org

drivers/ide is obsolete and on its way out.

drivers/ata replaced it as the old code couldn't really cope with things
like SATA NCQ or hotplug. The new stuff can which is probably handy in a
hypervisor.

> 		ii. SCSI/Storvsc		James Bottomley

Yes & linux-scsi@vger.kernel.org

> 		iii. Network/Netvsc	Stephen Hemminger
> 	2. What is the process to submit the code for review?

See: Documentation/SubmittingPatches in your kernel tree

That should answer the rest. If not then keep a tag on things that should
have been in there but weren't and that can also get updated.
