From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC-PATCH] dhcp provisioning support in cxgb3i
Date: Thu, 29 Oct 2009 14:06:54 +0000
Message-ID: <1256825214.2827.10.camel@achroite>
References: <4AE995C4.4080909@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>, davem@davemloft.net,
	James Bottomley <James.Bottomley@suse.de>,
	Karen Xie <kxie@chelsio.com>,
	"open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	netdev@vger.kernel.org
To: Rakesh Ranjan <rakesh@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754357AbZJ2OGy@vger.kernel.org>
In-Reply-To: <4AE995C4.4080909@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-10-29 at 18:46 +0530, Rakesh Ranjan wrote:
> Hi Mike,
> 
> Herein attached patches for having dhcp provisioning support in
> cxgb3i. 
> I have added one new iscsi netlink message ISCSI_UEVENT_REQ_IPCONF. 
> Please have a look and share suggestions.
[...]

Why does cxgb3i need its very own DHCP client?  This seems like
something that's generically useful to firmware-based iSCSI adapters.

(It would be better still if this could be left to user-space, but
although a user-space program could send out requests on the net device
using the iSCSI device's MAC address, I don't see how it would get
replies.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
