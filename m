From: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Subject: Re: [PATCH v4] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Thu, 28 May 2015 10:26:43 -0300
Message-ID: <87zj4osui4.fsf@sycorax.br.ibm.com>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
	<20150430.160537.232956261880122754.davem@davemloft.net>
	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org>
	<87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<55658781.8060104@redhat.com>
	<B5657A6538887040AD3A81F1008BEC63DA8E49@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>,
	"LinoSanfilippo\@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo\@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking\@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:56894 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbE1N0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 09:26:50 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krisman@linux.vnet.ibm.com>;
	Thu, 28 May 2015 10:26:48 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 1C8B33520062
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 09:25:42 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4SDPVQj64946242
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 10:25:31 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4SDQiPY021526
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 10:26:45 -0300
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63DA8E49@avmb3.qlogic.org> (Yuval
	Mintz's message of "Thu, 28 May 2015 07:24:22 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <Yuval.Mintz@qlogic.com> writes:

> Actually, this upsets me greatly. We didn't see it on a system with 4KB
> pages, but this means you've actually tried to 'sell' us a fastpath fix that
> was never tested on machines for which it was meant as an improvement.

The iteration that inserted this bug was such a quick fix that I didn`t
bother rerunning it.  It just modified the type variable.  Take my word
it was a one time honest mistake.

The last iteration, as well as all of the previous ones were tested on
Power servers with bnx2x adapters.  The tests included stressing the
device and several iterations of hotplugging the adapter, helping us to
verify correctness of the rx queue operation as well as verifying that DMA
mapping/unmapping were correct.

-- 
Gabriel Krisman Bertazi
