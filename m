From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 05 Apr 2007 10:17:40 +0300
Message-ID: <4614A294.3000607@qumranet.com>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
 <20070404212103.GA19026@elte.hu>
 <1175728768.12230.593.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout4.012.net.il ([84.95.2.10]:56570 "EHLO mtaout4.012.net.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbXDEHRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 03:17:42 -0400
Received: from firebolt.argo.co.il ([80.178.163.252])
 by i_mtaout4.012.net.il (HyperSendmail v2004.12)
 with ESMTP id <0JG000L8SKNIFI00@i_mtaout4.012.net.il> for
 netdev@vger.kernel.org; Thu, 05 Apr 2007 10:26:06 +0300 (IDT)
In-reply-to: <1175728768.12230.593.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> You didn't quote Anthony's point about "it's more about there not being
> good enough userspace interfaces to do network IO."
>
> It's easier to write a kernel-space network driver, but it's not
> obviously the right thing to do until we can show that an efficient
> packet-level userspace interface isn't possible.  I don't think that's
> been done, and it would be interesting to try.
>   

In the case of networking, the copyful interfaces on receive are driven 
by the hardware not knowing how to split the header from the data.  On 
transmit I agree, it could be made copyless from userspace (somthing 
like sendfilev, only not file oriented).

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

