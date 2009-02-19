From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH 2/7] net: add FCoE offload support through net_device
Date: Thu, 19 Feb 2009 13:32:44 -0800
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2222427B83D@orsmsx509.amr.corp.intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
	<20090219194949.22270.40834.stgit.yi.zou@intel.com>
 <20090219132420.4b0dfc09@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090219132420.4b0dfc09@extreme>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>On Thu, 19 Feb 2009 12:49:49 -0700
>Yi Zou <yi.zou@intel.com> wrote:
>
>> This adds a "struct net_fcoe_ops *fcoe_ops" to net_device struct so
>any
>> network adapter driver can provide Fiber Channle over Ethernet (FCoE)
>offload
>> support through net_device. The fcoe_ops is only available when FCoE
>is
>> enabled in kernel as built-in or module driver.
>>
>> Signed-off-by: Yi Zou <yi.zou@intel.com>
>
>Rather than adding another _ops structure please add to existing
>netdevice_ops. You don't need the flags that way. If netdevice_ops
>has fcoe_setup, then device can do it...
The comments in struct net_device_ops says for management hooks, if
that's an ok place for net_fcoe_ops, then, I am all for it.

Thanks.

yi
