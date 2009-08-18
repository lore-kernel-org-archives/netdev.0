From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model	 for
Date: Tue, 18 Aug 2009 15:29:08 +0300
Message-ID: <4A8A9E94.9020700@redhat.com>
References: <4A8A654A0200005A000528E7@sinclair.provo.novell.com> <4A8A65540200005A000528EA@sinclair.provo.novell.com> <4A8A65540200005A000528EA@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, gregory.haskins@gmail.com,
	alacrityvm-devel@lists.sourceforge.net, mst@redhat.com,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <GHaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8A65540200005A000528EA@sinclair.provo.novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 03:24 PM, Gregory Haskins wrote:
> (Again on the top post)
>
> No, Avi, nothing has changed to my knowledge.  I just saw that you and Michael were heading down the same path, so I thought I might interject that we've already covered that ground.
>
> As of right now, I am of the opinion that its not worth any change in the short term, and may be worth IOoHC in the long term (primarily so that mmios get a boost)
>    

The primary issue with IOoHC is that while hypercalls are faster than 
emulated mmio, they're much slower than assigned mmio.  So we have to 
distinguish between these two cases, which gets kinda icky.

-- 
error compiling committee.c: too many arguments to function

