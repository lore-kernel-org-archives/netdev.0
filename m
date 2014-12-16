From: rapier <rapier@psc.edu>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 15:01:49 -0500
Message-ID: <54908FAD.5060500@psc.edu>
References: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com> <20141216.140919.44020047339373813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:40982 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbaLPUBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 15:01:52 -0500
In-Reply-To: <20141216.140919.44020047339373813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/16/14, 2:09 PM, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 16 Dec 2014 10:24:31 -0800
>
>> imo that is very questionable design choice.
>> export a lot of in-kernel bits to be used by out-of-tree kernel module?
>
> It's a non-starter.

Understood. We're in the process of reviewing which symbols are required 
by the DLKM we've provided and which are required by in tree modules 
(e.g tcp_estats_enabled is required by tcp_htcp). In the meantime, I do 
want to stress that the KIS is distinct from the control and management 
functions in this patch. We'd like to make sure that problems with this 
patch aren't negating the value of the instrument set.
