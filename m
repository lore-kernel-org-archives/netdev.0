From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 13:28:45 -0800
Message-ID: <1296595725.26937.819.camel@localhost.localdomain>
References: <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110201172346.GA24392@redhat.com>
	 <1296590943.26937.797.camel@localhost.localdomain>
	 <20110201201715.GA30050@redhat.com>
	 <1296591908.26937.809.camel@localhost.localdomain>
	 <20110201212110.GC30770@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, steved@us.ibm.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110201212110.GC30770@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-02-01 at 23:21 +0200, Michael S. Tsirkin wrote:
> Confused. We compare capacity to skb frags, no?
> That's sg I think ...

Current guest kernel use indirect buffers, num_free returns how many
available descriptors not skb frags. So it's wrong here.

Shirley

