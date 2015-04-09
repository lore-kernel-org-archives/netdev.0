From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Thu, 09 Apr 2015 11:07:11 +0200
Message-ID: <2761020.mMbmnV3vx2@msg-id>
References: <2142872.6QHf5ZAfZz@msg-id> <5635504.5jEhSFiGfj@msg-id> <CAKD1Yr2sFyx59FH2wCH_okAadv7dJxGQZtqAa56p6kYXDW-VBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35410 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933881AbbDIJHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 05:07:35 -0400
Received: by wgyo15 with SMTP id o15so102480143wgy.2
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 02:07:34 -0700 (PDT)
In-Reply-To: <CAKD1Yr2sFyx59FH2wCH_okAadv7dJxGQZtqAa56p6kYXDW-VBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti wrote:
> On Wed, Apr 8, 2015 at 10:05 PM, Salvatore Mesoraca <s.mesoraca16@gmail.com>
> wrote:
> > > And, would you provide patch for ping6 as well?
> > 
> > I was planning to work on ping6 as well If this patch get accepted.
> 
> Yoshifuji-san,
> 
> I sent you a patch that works for both IPv4 and IPv6 a couple of years ago:
> 
> http://marc.info/?l=linux-netdev&m=137026384215378
> http://marc.info/?l=linux-netdev&m=137026384815379
> 
> This code has been running on Android since then:
> 
> https://android-review.googlesource.com/#/c/61948/
> 
> Perhaps we can start from that patchset?
> 
> Cheers,
> Lorenzo

Hi Lorenzo,
Thank you for bringing this up,
it seems that you have a better understanding than mine on the original patch.

Anyway I'm wondering why you didn't include this change:

> -             if (!working_recverr) {
> +             if (!using_ping_socket && !working_recverr) {

inside receive_error_msg()
The code in the if block try to execute a setsockopt(icmp_sock, SOL_RAW, 
ICMP_FILTER, ...) which is only possible on a raw socket.
What am I missing?
Thank you for your patience,
I hope this time your patch get accepted,

Salvatore Mesoraca
