From: Dave Taht <dave.taht@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 19:54:08 +0100
Message-ID: <CAA93jw60L+mxEPnxBeruSsZUZKPBy=N3oWTvQQbsJFk9pwvhAw@mail.gmail.com>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	<20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	<1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	<1324664907.2915.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47685 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594Ab1LWSyJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 13:54:09 -0500
Received: by iaeh11 with SMTP id h11so15471764iae.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 10:54:08 -0800 (PST)
In-Reply-To: <1324664907.2915.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 23, 2011 at 7:28 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 23 d=E9cembre 2011 =E0 18:54 +0100, Dave Taht a =E9crit :
>
>> Are there any place where all 48 bytes of cb are used?
>>
>
> Yes, but on in qdisc layer.
>
> struct tcp_skb_cb is known to be 44 bytes (when IPv6 is enabled)
>
> In qdisc layer, we use a small part of it, for the moment.
>
>> I wouldn't mind if 'time_to_send' became a separate skb field
>> for a more generic 'time_in_queue'...
>>
>
> This wont happen.
>
> As I posted in an earlier patch, this can be added in "struct
> qdisc_skb_cb"

Ah... this patch?

http://patchwork.ozlabs.org/patch/125329/

I liked what I saw then, but nobody chirped up to review it...

I guess I know what I'm doing this weekend.

>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
