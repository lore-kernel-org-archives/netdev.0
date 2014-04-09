From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: question: update_pmtu doesn't update dst mtu
Date: Wed, 9 Apr 2014 22:30:10 +0200
Message-ID: <20140409203010.GE27255@order.stressinduktion.org>
References: <533D47FD.9020904@securitycode.ru> <20140403115809.GA13354@order.stressinduktion.org> <533D4EF9.60608@securitycode.ru> <20140403121410.GC13354@order.stressinduktion.org> <533D5398.7080209@securitycode.ru> <5343BB6F.2090601@securitycode.ru> <20140408145718.GC27255@order.stressinduktion.org> <5345021D.30505@securitycode.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33397 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933776AbaDIUaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 16:30:12 -0400
Content-Disposition: inline
In-Reply-To: <5345021D.30505@securitycode.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 12:17:33PM +0400, Ilya V. Matveychikov wrote:
> Works fine, thanks! By the way, could you briefly explain why routes are
> separated to input and output? What are the benefits?

Core routing table is not split by input and output, merely the dst
construction and surrounding lookup and policy checks are seperated for input
and output.

Output does not have to deal with source address validation e.g. but has to do
source address selection.

Quite hard to answer, I guess the design emerged quite naturally. ;)

Bye,

  Hannes
