From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [Cbe-oss-dev] [PATCH 4/10] spidernet: zero out a pointer.
Date: Wed, 23 May 2007 02:29:52 +0200
Message-ID: <de086868a64685afb768ecd78423a14f@kernel.crashing.org>
References: <20070516215605.GA4325@austin.ibm.com> <20070516220928.GD4997@austin.ibm.com> <1179358376.4142.4.camel@concordia.ozlabs.ibm.com> <20070522233517.GU5921@austin.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, cbe-oss-dev@ozlabs.org,
	Michael Ellerman <michael@ellerman.id.au>,
	netdev@vger.kernel.org
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-04.arcor-online.net ([151.189.21.44]:58158 "EHLO
	mail-in-04.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762032AbXEWA35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 20:29:57 -0400
In-Reply-To: <20070522233517.GU5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> If you're going to be paranoid, shouldn't you do something here to 
>> make
>> sure the value's hit the device?
>
> I thought the whole point of paranoia is that its inexplicable.
>
> Here's a delusional reply: I didn't see any point to it.
> 1) a wmb would add overhead

A wmb() doesn't guarantee the write has reached the device.

> 2) the hardware is supposed to be looking at the status flag,
>    anyway, and not misbehaving.

But you're paranoid, right?  Can't trust that device! :-)


Segher

