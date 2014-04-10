From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Thu, 10 Apr 2014 12:28:49 +0400
Message-ID: <53465641.4070407@securitycode.ru>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org> <533D4EF9.60608@securitycode.ru> <20140403121410.GC13354@order.stressinduktion.org> <533D5398.7080209@securitycode.ru> <5343BB6F.2090601@securitycode.ru> <20140408145718.GC27255@order.stressinduktion.org> <5345021D.30505@securitycode.ru> <20140409203010.GE27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:61260 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965097AbaDJI2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 04:28:12 -0400
In-Reply-To: <20140409203010.GE27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.04.2014 00:30, Hannes Frederic Sowa wrote:
> On Wed, Apr 09, 2014 at 12:17:33PM +0400, Ilya V. Matveychikov wrote:
>> Works fine, thanks! By the way, could you briefly explain why routes are
>> separated to input and output? What are the benefits?
> 
> Core routing table is not split by input and output, merely the dst
> construction and surrounding lookup and policy checks are seperated for input
> and output.
> 
> Output does not have to deal with source address validation e.g. but has to do
> source address selection.
> 
> Quite hard to answer, I guess the design emerged quite naturally. ;)

OK, I've got it. Thanks again.
