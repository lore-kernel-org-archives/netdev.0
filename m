From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Sun, 09 Aug 2009 10:48:34 +0300
Message-ID: <4A7E7F52.7020100@redhat.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <4A7AE150.7040009@redhat.com> <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com> <200908061740.04276.arnd@arndb.de> <4A7AFBE3.5080200@redhat.com> <4A7AD2D20200005A00051C83@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A7AD2D20200005A00051C83@sinclair.provo.novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2009 07:55 PM, Gregory Haskins wrote:
> Based on this, I will continue my efforts surrounding to use of vbus including its use to accelerate KVM for AlacrityVM.  If I can find a way to do this in such a way that KVM upstream finds acceptable, I would be very happy and will work towards whatever that compromise might be.   OTOH, if the KVM community is set against the concept of a generalized/shared backend, and thus wants to use some other approach that does not involve vbus, that is fine too.  Choice is one of the great assets of open source, eh?   :)
>    

KVM upstream (me) doesn't have much say regarding vbus.  I am not a 
networking expert and I'm not the virtio or networking stack maintainer, 
so I'm not qualified to accept or reject the code.  What I am able to do 
is make sure that kvm can efficiently work with any driver/device stack; 
this is why ioeventfd/irqfd were merged.

I still think vbus is a duplication of effort; I understand vbus has 
larger scope than virtio, but I still think these problems could have 
been solved within the existing virtio stack.

-- 
error compiling committee.c: too many arguments to function

