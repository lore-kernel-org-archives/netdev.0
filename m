From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Tue, 10 Mar 2015 21:39:06 -0700
Message-ID: <54FFC6EA.6080800@intel.com>
References: <54FFAA5B.3080608@intel.com>	<54FFB3E9.50905@windriver.com>	<54FFB5A9.5030008@intel.com> <20150311.000659.1763019676805929532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, herbert@gondor.apana.org.au, hch@lst.de,
	viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57043 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbbCKEli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 00:41:38 -0400
In-Reply-To: <20150311.000659.1763019676805929532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 09:06 PM, David Miller wrote:
>> In my opinion this is not about a single, special case, but rather
>> > about being able to support asynchronous operations on socket
>> > interface.
> Nobody used the socket AIO facility for two decades, it just
> rotted and turned out to be buggy and reference freed stack
> memory on top of that.
> 
> I am absolutely not convinced this is the only way to solve your
> problem.

Do you have any suggestion?
