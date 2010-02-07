From: jamal <hadi@cyberus.ca>
Subject: rps: question
Date: Sun, 07 Feb 2010 13:42:02 -0500
Message-ID: <1265568122.3688.36.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f191.google.com ([209.85.221.191]:40614 "EHLO
	mail-qy0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab0BGSmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 13:42:07 -0500
Received: by qyk29 with SMTP id 29so2775638qyk.23
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2010 10:42:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

First off: Kudos on the numbers you are seeing; they are
impressive. Do you have any numbers on a forwarding path test?

My first impression when i saw the numbers was one of suprise.
Back in the days when we tried to split stack processing the way
you did(it was one of the experiments on early NAPI), IPIs were 
_damn_ expensive. What changed in current architecture that makes
this more palatable? IPIs are still synchronous AFAIK (and the more
IPI receiver there are, the worse the ACK latency). Did you test this
across other archs or say 3-4 year old machines?

cheers,
jamal 

