From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 15:54:54 +0300
Message-ID: <4A7AD29E.50800@redhat.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090806081955.GA9752@redhat.com> <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755444AbZHFMtf@vger.kernel.org>
In-Reply-To: <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2009 03:08 PM, Gregory Haskins wrote:
>> Merging the guest first means relying on
>> kernel interface from an out of tree driver, which well might change
>> before it goes in.
>>      
>
> ABI compatibility is already addressed/handled, so even if that is true its not a problem.
>
>    

Really the correct way to address the ABI is to publish a spec and write 
both host and guest drivers to that.  Unfortunately we didn't do this 
with virtio.

It becomes more important when you have multiple implementations (e.g. 
Windows drivers).

>>> This series implements the guest-side drivers for accelerated IO
>>> when running on top of the AlacrityVM hypervisor, the details of
>>> which you can find here:
>>>
>>> http://developer.novell.com/wiki/index.php/AlacrityVM
>>>        
>> Since AlacrityVM is kvm based, Cc kvm@vger.kernel.org.
>>      
>
> I *can* do that, but there is nothing in these drivers that is KVM specific (its all pure PCI and VBUS).  I've already made the general announcement about the project/ml cross posted to KVM for anyone that might be interested, but I figure I will spare the general KVM list the details unless something specifically pertains to, or affects, KVM.  For instance, when I get to pushing the hypervisor side, I still need to work on getting that 'xinterface' patch to you guys.  I would certainly be CC'ing kvm@vger when that happens since it modifies the KVM code.
>
> So instead, I would just encourage anyone interested (such as yourself) to join the alacrity list so I don't bother the KVM community unless absolutely necessary.
>    

It's true that vbus is a separate project (in fact even virtio is 
completely separate from kvm).  Still I think it would be of interest to 
many kvm@ readers.


-- 
error compiling committee.c: too many arguments to function
