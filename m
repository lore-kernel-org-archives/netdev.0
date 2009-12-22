From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 21:43:17 +0200
Message-ID: <4B312155.7040308@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com> <4B311D20.7020400@redhat.com> <4B311ECB.6040205@gmail.com> <4B312042.7010804@redhat.com> <4B3120E2.7070307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B3120E2.7070307@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2009 09:41 PM, Gregory Haskins wrote:
>
>> It means that kvm locking suddenly affects more of the kernel.
>>
>>      
> Thats ok.  This would only be w.r.t. devices that are bound to the KVM
> instance anyway, so they better know what they are doing (and they do).
>
>    

It's okay to the author of that device.  It's not okay to the kvm 
developers who are still evolving the locking and have to handle all 
devices that use xinterface.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

