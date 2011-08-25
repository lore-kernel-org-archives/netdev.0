From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Traffic shaping - class ID 16bit limit?
Date: Thu, 25 Aug 2011 09:39:37 -0700
Message-ID: <20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
References: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54765 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754471Ab1HYQj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 12:39:28 -0400
In-Reply-To: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2011 18:28:01 +0200
Miroslav Kratochvil <exa.exa@gmail.com> wrote:

> Technically the ClassID seems to be "hardcoded" as a 16bit value, but
> after some source searching, I haven't found any good reason for it to
> be 16-bit only.

Granted it was a poor choice in the initial design.
It is wired into the API and changing it would be quite painful.

You might be able to do the same thing by splitting traffic
into multiple virtual devices (dummy or ifb) and then doing
another layer.
