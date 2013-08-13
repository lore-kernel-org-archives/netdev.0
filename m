From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: question about netif_rx
Date: Tue, 13 Aug 2013 22:41:31 +0200
Message-ID: <20130813204131.GA4696@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
 <20130811155640.GA10070@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
 <20130813052036.GA11640@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6>
 <CAJJAcocQ59Kc9a1b=jrNSc1akLLN_74yKANMEmLVmvxoRjX4hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, grant.likely@linaro.org,
	rob.herring@calxeda.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJJAcocQ59Kc9a1b=jrNSc1akLLN_74yKANMEmLVmvxoRjX4hw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(no top-post nor lazy quote please)

David Shwatrz <dshwatrz@gmail.com> :
[...]
> In the napi_gro_receive() we check that the device supports
> NETIF_F_GRO, but I don't see that we inspect checksum or that
> NETIF_F_GRO is depends on checksum.

napi_gro_receive is irrelevant. Let aside tunnel, the real work happens
in the protocol specific gro_receive handlers.

However I am an happy retard and I missed that tcp gro stopped depending
on Rx checksum since commit 861b650101eb0c627d171eb18de81dddb93d395e. :o/

So, yes, napi_gro_receive could be used.

-- 
Ueimor
