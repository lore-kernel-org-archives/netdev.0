From: Einar Lueck <elelueck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] tcp: introduce raw access to experimental options
Date: Wed, 21 Nov 2012 15:26:30 +0100
Message-ID: <50ACE496.20705@linux.vnet.ibm.com>
References: <1353084898-42264-1-git-send-email-elelueck@linux.vnet.ibm.com> <20121116.134424.1929556546744828875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frankbla@de.ibm.com, raspl@de.ibm.com,
	ubacher@de.ibm.com, samudrala@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:48909 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab2KUO0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 09:26:37 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Wed, 21 Nov 2012 14:26:35 -0000
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qALEQO2856688648
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 14:26:24 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qALEQViY003853
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 07:26:31 -0700
In-Reply-To: <20121116.134424.1929556546744828875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2012 07:44 PM, David Miller wrote:
>
> Unprivileged access to set and fetch these things?  I don't think
> that's a good idea.
>
> Also, your code has a lot of coding style errors.
>

Would a restriction to a CAP_NET_ADMIN like privilege level address and 
resolve your concerns?

Thx,
Einar.
