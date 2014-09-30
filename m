From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen/xenbus: Use 'void' instead of 'int' for the return
 of xenbus_switch_state()
Date: Tue, 30 Sep 2014 10:55:26 +0100
Message-ID: <542A7E0E.9050702@citrix.com>
References: <5425961A.5000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>, <konrad.wilk@oracle.com>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<boris.ostrovsky@oracle.com>, <bhelgaas@google.com>,
	<jgross@suse.com>, <yongjun_wei@trendmicro.com.cn>,
	<mukesh.rathor@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5425961A.5000604@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/09/14 17:36, Chen Gang wrote:
> When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
> internally, so need not return any status value, then use 'void' instead
> of 'int' for xenbus_switch_state() and __xenbus_switch_state().
> 
> Also need be sure that all callers which check the return value must let
> 'err' be 0.
> 
> And also need change the related comments for xenbus_switch_state().

Since this patch does not fix a bug and there is no unanimous agreement
on the API change I'm not going to apply it (nor the previous version).

David
