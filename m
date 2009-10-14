From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 22:34:17 +0200
Message-ID: <C803B824-8249-44BA-ACCD-D9AE4AA21F92@ntop.org>
References: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org> <20091014.131526.181354809.davem@davemloft.net> <A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org> <20091014.132911.174712308.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, brad.doctor@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:40709 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487AbZJNUfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:35:00 -0400
In-Reply-To: <20091014.132911.174712308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David
so do you want me to start porting PF_RING facilities into PF_PACKET?  
As I have said I;m not against this: my goal is to include this work  
into the linux kernel, as it has been separate for too long.

Luca

On Oct 14, 2009, at 10:29 PM, David Miller wrote:

> From: Luca Deri <deri@ntop.org>
> Date: Wed, 14 Oct 2009 22:26:25 +0200
>
>> I agree that some PF_RING features could be merged into
>> PF_PACKET. However PF_RING is not just about improving packet capture
>> but it implements facilities that can be used by many monitoring
>> applications including, packet balancing, reflection, layer-7 packet
>> filtering, pf_ring socket clustering just to name a few. You can read
>> about PF_RING feature into this tutorial:
>> http://luca.ntop.org/IM2009_Tutorial.pdf
>
> I've already researched several times what PF_RING does and
> is capable of doing, and my position still stands that none of
> it can't be added to existing facilities.
>
> It's been an out of tree hack for years, and if it stays as
> a seperate facility it's likely to stay that way.

