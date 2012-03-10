From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC PATCH v1 4/4] ixgbe: enable FDB netdevice ops
Date: Fri, 09 Mar 2012 19:48:38 -0800 (PST)
Message-ID: <ba6647b4-1242-4753-9e97-9a2f5515b20c@tahiti.vyatta.com>
References: <20120309224812.2514.88137.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, roprabhu@cisco.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, davem@davemloft.net,
	gregory v rose <gregory.v.rose@intel.com>,
	kvm@vger.kernel.org, sri@us.ibm.com, chealy@imsco-us.com,
	jhs@mojatatu.com, bhutchings@solarflare.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120309224812.2514.88137.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Enable FDB ops on ixgbe when in SR-IOV mode.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Will all this break anything on the vf client? What if the vf is running
a bridge.
