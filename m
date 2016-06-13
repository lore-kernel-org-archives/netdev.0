From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] eBPF JIT for PPC64
Date: Mon, 13 Jun 2016 11:10:59 +0530
Message-ID: <20160613054055.GV18654@naverao1-tp.localdomain>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <20160610.224755.1614979708956751311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, matt@ozlabs.org, kda@linux-powerpc.org,
	paulus@samba.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com
To: David Miller <davem@davemloft.net>,
	Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44419 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932181AbcFMFmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 01:42:04 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5D5YHlW145371
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 01:42:03 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23gbjudadj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 01:42:03 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 15:42:00 +1000
Content-Disposition: inline
In-Reply-To: <20160610.224755.1614979708956751311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/06/10 10:47PM, David Miller wrote:
> From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
> Date: Tue,  7 Jun 2016 19:02:17 +0530
> 
> > Please note that patch [2] is a pre-requisite for this patchset, and is
> > not yet upstream.
>  ...
> > [1] http://thread.gmane.org/gmane.linux.kernel/2188694
> > [2] http://thread.gmane.org/gmane.linux.ports.ppc.embedded/96514
> 
> Because of #2 I don't think I can take this directly into the networking
> tree, right?
> 
> Therefore, how would you like this to be merged?

Hi David,
Thanks for asking. Yes, I think it is better to take this through the 
powerpc tree as all the changes are contained within arch/powerpc, 
unless Michael Ellerman feels differently.

Michael?


Regards,
Naveen
