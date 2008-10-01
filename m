From: Joe Nall <joe@nall.com>
Subject: Re: [RFC PATCH v6 12/16] selinux: Set socket NetLabel based on connection endpoint
Date: Wed, 1 Oct 2008 09:51:31 -0500
Message-ID: <7DC4373B-194C-43FC-B4FB-B867999CAE76@nall.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125709.17132.47022.stgit@flek.lan> <alpine.LRH.1.10.0810011958380.6732@tundra.namei.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-01-bos.mailhop.org ([63.208.196.178]:60748 "EHLO
	mho-01-bos.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbYJAOvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:51:51 -0400
In-Reply-To: <alpine.LRH.1.10.0810011958380.6732@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2008, at 5:00 AM, James Morris wrote:

> On Tue, 16 Sep 2008, Paul Moore wrote:
>
>> /**
>> + * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
>> + * @sk: the socket
>> + *
>> + * Description:
>> + * Removes the CIPSO option from a socket, if present.
>> + *
>> + */
>> +void cipso_v4_sock_delattr(struct sock *sk)
>
> Reviewed-by: James Morris <jmorris@namei.org>
>
>
> Btw, what kind of testing has this patch had?

Paul generated a patch for us against 2.6.26-5 that we have on about  
20 developer and test boxes with good results in MLS enforcing. We are  
adding IPSec between machines and static fallback labels  to the test  
mix and will report any issues. We have a couple of 8 core machines  
I'll stress test on to look for SMP issues.

joe


