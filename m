From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Mon, 23 Jul 2012 10:18:41 -0300
Message-ID: <500D4F31.9020408@linux.vnet.ibm.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <500BD558.2060803@mellanox.com> <20120722.171553.2139258607165498367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	shlomop@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:37159 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab2GWNSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 09:18:53 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 10:18:51 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 2CD27352004C
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 09:18:46 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6NDFJUB3231850
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 10:15:19 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6NBIfeB029432
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 08:18:43 -0300
In-Reply-To: <20120722.171553.2139258607165498367.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2012 09:15 PM, David Miller wrote:

> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun, 22 Jul 2012 13:26:32 +0300
> 
>> is there anything in the code you added which maybe implicitly
>> assumes PPC arch?
> 
> He implemented support for a standard PCI API in the kernel, he
> happened to test it on a particular platform, and I think that's
> the long and short of it.
> 


Exactly. The callbacks implemented are from standard PCI error recovery
(Documentation/PCI/pci-error-recovery.txt) and the changes doesn't
assume any platform in specific. The code was tested only on powerpc
systems since I don't have any mlx4 card on other platforms, however,
these changes shouldn't make the error recover any worse than the
current state.

-- 
Kleber Sacilotto de Souza
IBM Linux Technology Center
