From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model
Date: Tue, 18 Aug 2009 16:47:42 +0300
Message-ID: <4A8AB0FE.1010204@redhat.com>
References: <4A8A67ED0200005A000528F5@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com> <4A8AA0C6.805@redhat.com> <4A8AAA67.8060602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <GHaskins@novell.com>, mingo@elte.hu,
	alacrityvm-devel@lists.sourceforge.net, mst@redhat.com,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758960AbZHRNsH@vger.kernel.org>
In-Reply-To: <4A8AAA67.8060602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 04:19 PM, Gregory Haskins wrote:
> Yeah, exactly.  I think MMIO is particularly challenging because I don't
> know if there are any bits left to use.  But like I said, its a problem
> for another day IMO.
>    

x86_64 only uses 48 bits out of the 64 bits in a virtual address, so 
there are several guaranteed-unused bits.

-- 
error compiling committee.c: too many arguments to function
