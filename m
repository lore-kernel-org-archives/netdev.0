From: Michael Mueller <mimu@linux.vnet.ibm.com>
Subject: Re: [PATCH v1] vhost: avoid large order allocations
Date: Tue, 13 May 2014 10:57:41 +0200
Message-ID: <20140513105741.0cc3c159@bee>
References: <1399970133-46783-1-git-send-email-mimu@linux.vnet.ibm.com>
	<1399970133-46783-2-git-send-email-mimu@linux.vnet.ibm.com>
	<20140513084049.GE29442@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	borntraeger@de.ibm.com, cornelia.huck@de.ibm.com,
	ddongch@cn.ibm.com, mimu@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140513084049.GE29442@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2014 11:40:49 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Please dont' do this, extra indirection hurts performance.
> Instead, please change vhost_net_open and scsi to allocate the whole
> structure with vmalloc if kmalloc fails, along the lines of
> 74d332c13b2148ae934ea94dac1745ae92efe8e5

Thanks for pointing us to: net: extend net_device allocation to vmalloc()

We'll try to adapt.

Michael  
