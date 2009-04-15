From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Wed, 15 Apr 2009 12:26:53 +0200
Message-ID: <49E5B66D.30602@trash.net>
References: <20090410191736.21efab8c@mako-desktop> <49E4744D.5090205@trash.net> <49E47C2D.1050508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netfilter Development Mailinglist
	<netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49E47C2D.1050508-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> I should have used different fields names (from "next", "first", ...) to catch this
> kind of errors at compile time :(
> 
> Something like :
> 
> diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h

Eric, on second thought, could you please resubmit this to Dave?
It touches too many files outside of netfilter to go through my
tree.
