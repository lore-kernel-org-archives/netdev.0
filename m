From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 22:26:25 +0200
Message-ID: <A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <200910141319.43884.bcook@bpointsys.com> <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org> <20091014.131526.181354809.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, brad.doctor@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:41983 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933930AbZJNU1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:27:09 -0400
In-Reply-To: <20091014.131526.181354809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David
I agree that some PF_RING features could be merged into PF_PACKET.  
However PF_RING is not just about improving packet capture but it  
implements facilities that can be used by many monitoring applications  
including, packet balancing, reflection, layer-7 packet filtering,  
pf_ring socket clustering just to name a few. You can read about  
PF_RING feature into this tutorial: http://luca.ntop.org/IM2009_Tutorial.pdf

So if the decision is to include in PF_PACKET some unique features  
present in PF_RING, I will not be against that, even if I think that  
the PF_RING design is different from PF_PACKET, that IMHO is limited  
to packet capture.

Regards Luca


On Oct 14, 2009, at 10:15 PM, David Miller wrote:

> From: Luca Deri <deri@ntop.org>
> Date: Wed, 14 Oct 2009 21:54:26 +0200
>
>> - packets to be filtered using both BPF and ACL-like filters
>
> To me this is all that PF_RING adds, the ACL filter features.
>
> And I see no reason why that can't be added to PF_PACKET, we've
> extended PF_PACKET in many ways before (even the mmap ring
> buffer layout can be modified trivially) so there is no reason
> we can't add the ACL filter feature to PF_PACKET as well.
>
> Adding all of PF_RING just for that is a joke.

