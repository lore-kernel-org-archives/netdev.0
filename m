From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] rps and pvdrivers
Date: Fri, 3 Sep 2010 14:05:35 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: Chetan Loke <chetanloke@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:40754 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752542Ab0ICVFh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 17:05:37 -0400
In-Reply-To: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chetan,

I presume you're talking about the vmxnet3 vNIC here? What version of the VMware hypervisor are you observing this with? Could you share the vmware.log (and potentially the vmkernel log) file from the VM where you're seeing this?

Thanks.

- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Chetan Loke
> Sent: Friday, September 03, 2010 12:49 PM
> To: netdev@vger.kernel.org; pv-drivers@vmware.com; therbert@google.com
> Subject: [Pv-drivers] rps and pvdrivers
> 
> Hello,
> 
> I just tried kernel-2.6.35-0.57.rc6.git1.fc14.x86_64.rpm because
> ksoftirqd was consuming 100% cpu under high packet load(on a 10G
> vNIC). Now with the above combo the vNIC on the monitoring interface
> virtually receives 'zero' interrupts.
> Do I have to configure anything manually? Things work fine with 2.6.33
> and I can capture 250K+ packets but I can't use it on a 10G NIC. I'm
> going to try the stock 2.6.35.4 to see if I get the same results.
> 
> Is anyone else seeing similar issues?
> 
> 
> Chetan Loke
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
