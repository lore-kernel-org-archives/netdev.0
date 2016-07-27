From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 27 Jul 2016 09:20:48 +0000
Message-ID: <CO2PR03MB2182B2EDF306221382C160BCBF0F0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <20160725.213822.1745865660912873332.davem@davemloft.net>
	<CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
	<CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160726.104435.102819545292415024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160726.104435.102819545292415024.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 27, 2016 1:45
> To: Dexuan Cui <decui@microsoft.com>
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Tue, 26 Jul 2016 07:09:41 +0000
> 
> > I googled "S390 hypervisor socket" but didn't find anything related (I think).
> 
> That would be net/iucv/
Thanks for the info! I'll look into this.
 
> There's also VMWare's stuff under net/vmw_vsock
> 
> It's just absolutely rediculous to make a new hypervisor socket
> interface over and over again, so much code duplication and
> replication.
I agree on this principle of avoiding duplication.
However my feeling is: IMHO different hypervisor sockets were developed
independently without coordination and the implementation details could be
so different that an enough generic framework/infrastructure is difficult,
e.g., at first glance, it looks AF_IUCV is quite different from AF_VSOCK and
this might explain why AF_VSOCK wasn't built on AF_IUCV(?).

I'll dig more into AF_IUCV, AF_VSOCK and AF_HYPERV and figure out what
is the best direction I should go.

Thanks,
-- Dexuan
