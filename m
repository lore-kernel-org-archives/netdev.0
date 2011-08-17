From: Emil S Tantilov <emils.tantilov@gmail.com>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 10:10:33 -0700
Message-ID: <CANh3MnZnyuvdiMyQTKKN=v-+y98FGbu+zA+=D4VnFL41AgRHpw@mail.gmail.com>
References: <4E4BF456.9000807@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:47847 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab1HQRKe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 13:10:34 -0400
Received: by qwk3 with SMTP id 3so678067qwk.19
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2011 10:10:33 -0700 (PDT)
In-Reply-To: <4E4BF456.9000807@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2011 at 10:03 AM, Stephen Clark <sclark46@earthlink.net=
> wrote:
> Hello List,
>
> Firstly thank you for your patience. =C2=A0I am replacing a bunch of =
=46reeBSD
> vpn/fw/routers
> with a Linux based system.
>
> I have run into a situation where if I ping our HQ the response comes=
 back
> on a different
> interface than what the request went out on. FreeBSD is happy and say=
s it
> got the response,
> Linux is not and gives no indication it got a response.

Try enabling ARP filtering:
echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter

Thanks,
Emil
