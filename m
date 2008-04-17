From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram implementation
Date: Thu, 17 Apr 2008 08:26:12 -0500
Message-ID: <B9622B0A-92E6-4787-8C5E-F54982F10556@kernel.crashing.org>
References: <20080320173945.GA8446@localhost.localdomain><20080414181810.GA1038@polina.dev.rtsoft.ru> <20080416182214.GA20056@polina.dev.rtsoft.ru> <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: <avorontsov@ru.mvista.com>, "Wood Scott" <scottwood@freescale.com>,
	<linuxppc-dev@ozlabs.org>, "Jeff Garzik" <jgarzik@pobox.com>,
	"Tabi Timur" <timur@freescale.com>, <netdev@vger.kernel.org>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55707 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548AbYDQN2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 09:28:19 -0400
In-Reply-To: <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 16, 2008, at 10:38 PM, Li Yang wrote:
>> -----Original Message-----
>> From: linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org
>> [mailto:linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org]
>> On Behalf Of Anton Vorontsov
>> Sent: Thursday, April 17, 2008 2:22 AM
>> To: Kumar Gala
>> Cc: Wood Scott; linuxppc-dev@ozlabs.org; Jeff Garzik; Tabi
>> Timur; netdev@vger.kernel.org
>> Subject: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to
>> the cpm_muramimplementation
>>
>> This is very trivial patch. We're transitioning to the
>> cpm_muram_* calls. That's it.
>
> Hi Anoton,
>
> It is a good thing to unify the CPM dpram operation and QE muram  
> operation.  But I'm having concerns about the naming as CPM is an  
> obsolete block.  Can we change to use the new name QE instead?

or at least provide both names by a simple:

#define qe_muram_addr cpm_muram_addr

- k
