From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 11:59:48 +0100
Message-ID: <54E31F24.1060705@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com> <20150217090242.GA20254@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Igor Mammedov <imammedo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217090242.GA20254@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17/02/2015 10:02, Michael S. Tsirkin wrote:
> > Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> > to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> > 
> > Signed-off-by: Igor Mammedov <imammedo@redhat.com>
>
> This scares me a bit: each region is 32byte, we are talking
> a 16K allocation that userspace can trigger.

What's bad with a 16K allocation?

> How does kvm handle this issue?

It doesn't.

Paolo
