From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 26 Jul 2016 10:44:35 -0700 (PDT)
Message-ID: <20160726.104435.102819545292415024.davem@davemloft.net>
References: <20160725.213822.1745865660912873332.davem@davemloft.net>
	<CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
	<CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, olaf@aepfle.de, gregkh@linuxfoundation.org,
	jasowang@redhat.com, dave.scott@docker.com,
	linux-kernel@vger.kernel.org, joe@perches.com,
	rolf.neugebauer@docker.com, netdev@vger.kernel.org,
	apw@canonical.com, devel@linuxdriverproject.org,
	haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 26 Jul 2016 07:09:41 +0000

> I googled "S390 hypervisor socket" but didn't find anything related (I think).

That would be net/iucv/

There's also VMWare's stuff under net/vmw_vsock

It's just absolutely rediculous to make a new hypervisor socket
interface over and over again, so much code duplication and
replication.
