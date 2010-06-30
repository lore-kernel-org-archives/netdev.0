From: Ivan Novick <novickivan@gmail.com>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 13:14:04 -0700
Message-ID: <AANLkTimpofANvn-sDZrE3kdq9owzYe8DJa8OfuVK04cM@mail.gmail.com>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
	<9E73042B-BF54-48FD-8755-C215FD03C9AE@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38625 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198Ab0F3UOF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:14:05 -0400
Received: by vws5 with SMTP id 5so1405933vws.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 13:14:04 -0700 (PDT)
In-Reply-To: <9E73042B-BF54-48FD-8755-C215FD03C9AE@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 1:06 PM, Mitchell Erblich
<erblichs@earthlink.net> wrote:
> On Jun 30, 2010, at 11:04 AM, Ivan Novick wrote:
=2E.. snip ...
> Sometimes, adding tracing within the tcps, can identify if.
> the tcp flow has periods of idleness,
> the tcp flow is/has been application limited versus network limited,
> whether the flow is in SS or CA?
> CA normally has DELayed ACks, which reduces the number
> =A0 =A0of ACKs to 1/2 or more,
> Whether Fast re-xmit is triggered by 2 or 3 DupAcks.
> whether any burst avoidance has occured,
> etc,

Hi Mitchell,

When you say adding tracing within the tcps... what method are you
referring to, to add this tracing?  Is it some tool or setting or are
you talking about adding custom debugging output to the kernel?

Cheers,
Ivan
