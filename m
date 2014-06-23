From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 10:02:42 +0200
Message-ID: <20140623080242.GA16924@aepfle.de>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de>
 <20140620051213.GA9960@kroah.com>
 <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Greg KH <greg@kroah.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 20, Haiyang Zhang wrote:

> This command ("/etc/init.d/network restart") exists on our supported distros
> currently. We will also look into some better ways to refresh the network for
> the distros without this command. I have tried setting IF_OPER_DORMANT then 
> IF_OPER_UP, but not working. I will look into the suspend/resume cycle as
> well.

I think its reasonable to expect guest config changes on this new kind
of host. Would a link-down/link-up event work? I'm sure it will, there
is enough code floating around in the guests which handles cable unplug. 

Olaf
