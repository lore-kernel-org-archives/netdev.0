From: Andi Kleen <andi@firstfloor.org>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds want to know why its set to zero)
Date: Thu, 17 Jul 2008 18:12:53 +0200
Message-ID: <87r69ssd4q.fsf@basil.nowhere.org>
References: <487E0C15.1070001@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:40069 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbYGQQNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 12:13:55 -0400
In-Reply-To: <487E0C15.1070001@linux-foundation.org> (Christoph Lameter's message of "Wed, 16 Jul 2008 09:56:21 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> There is some security reason why we set IP_ID == 0 right? Could someone point me at the discussions that lead to having IP_ID be zero? Have not been involved in network that much so forgive my ignorance.... and I can only find some hints about why this was done here and there using google.

AFAIK it was just for efficiency. The way Linux generates ipids
currently is somewhat expensive, because it aims to generate a per ip
ipid counter, so it was turned off when not needed. I used to patch
that out because it always seemed like overkill to me.

-Andi
