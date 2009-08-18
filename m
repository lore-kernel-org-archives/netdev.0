From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model
Date: Tue, 18 Aug 2009 15:38:30 +0300
Message-ID: <4A8AA0C6.805@redhat.com>
References: <4A8A67ED0200005A000528F5@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, gregory.haskins@gmail.com,
	alacrityvm-devel@lists.sourceforge.net, mst@redhat.com,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <GHaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8A67F70200005A000528F8@sinclair.provo.novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 03:36 PM, Gregory Haskins wrote:
> Yeah, I agree.  I am not advocating we expend energy on this now.  But my thoughts at the time were that that particular problem can be solved at io-setup time with some kind of call to qualify the address.
>
> Iow: a slow path call with the address would return flags on whether iowrite() should do a real io, or a IOoHC.
>    

Yes, it could work, though we'd need somewhere to stow this 
information.  IIRC Arnd suggested a bit from the address itself.

-- 
error compiling committee.c: too many arguments to function

