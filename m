From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Sat, 11 Nov 2006 07:37:43 +1100
Message-ID: <1163191063.4982.163.camel@localhost.localdomain>
References: <5cac192f0611091333w5740810bhe1966d6391c6d46a@mail.gmail.com>
	 <20061109.150436.94557169.davem@davemloft.net>
	 <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:3271 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S966112AbWKJUhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 15:37:51 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0611100528r4a53498emc8d866955cc36c8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Yes, the bit 4 isn't used, but I assumed clearing it shouldn't be prolem.

Always leave reserved bits alone ... I agree it's very unlikely in this
case that it could cause a problem but I've seen stranger things....

Ben.


