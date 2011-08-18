From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] bridge: allow passing link-local multicast
Date: Thu, 18 Aug 2011 08:10:19 -0700
Message-ID: <20110818081019.4b9bb79e@nehalam.ftrdhcpuser.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
	<20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
	<CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ed Swierk <eswierk@bigswitch.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	bridge@linux-foundation.org
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41889 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806Ab1HRPKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 11:10:10 -0400
In-Reply-To: <CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Aug 2011 16:06:19 +0100
Nick Carter <ncarter100@gmail.com> wrote:

> Why can't we use the 802.1D specified STP group address to identify ?
> The existing code uses that address.
> I know you said on another thread that there are people using other addresses.
> Who are these people ?
> Are they following any standard ?
> What address / address range are they using ?

The group address can be reprogrammed, and it is settable on other
routing equipment. People do it to create spanning tree domains.
