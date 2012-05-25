From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Fri, 25 May 2012 16:04:51 -0400
Message-ID: <4FBFE5E3.6080600@windriver.com>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>  <20120522.151830.2018953337014839778.davem@davemloft.net>  <4FBE4E02.1070306@computer.org> <1337876210.5070.4.camel@joe2Laptop>  <20120525155820.GA25102@windriver.com> <1337975465.30100.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	David Miller <davem@davemloft.net>, <b06378@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:54063 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab2EYUFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 16:05:04 -0400
In-Reply-To: <1337975465.30100.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-05-25 03:51 PM, Joe Perches wrote:
> On Fri, 2012-05-25 at 11:58 -0400, Paul Gortmaker wrote:
>> But you really shouldn't need the hardware to validate this kind of
>> patch anyways -- aside from your code flow change in the irq routine of
>> gianfar_ptp, you should have been simply able to check for object file
>> equivalence before and after your change.
> 
> No cross compiler either, and I'm lazy 'bout that...

Can't get much easier than using one of these:

http://www.kernel.org/pub/tools/crosstool/

Just untar, export PATH ARCH CROSS_COMPILE and go.

Can't get much lazier than that. Great to have around.

Paul.

> 
> cheers, Joe
> 
