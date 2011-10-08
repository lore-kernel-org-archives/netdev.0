From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] igb : rtnl assert on resume
Date: Sat, 08 Oct 2011 21:29:52 +0200
Message-ID: <1318102192.5276.27.camel@edumazet-laptop>
References: <1318096284.5276.25.camel@edumazet-laptop>
	 <1318098396.23688.169.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34726 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab1JHT35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 15:29:57 -0400
Received: by wyg34 with SMTP id 34so4825852wyg.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 12:29:56 -0700 (PDT)
In-Reply-To: <1318098396.23688.169.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 octobre 2011 =C3=A0 11:26 -0700, Jeff Kirsher a =C3=A9crit=
 :

> Any chance you can pull my net-next tree Eric to verify if the issue
> still exists?

Sure, I'll do that.

In the meantime, I upgraded my (slow, old) machine to ubuntu 11.11, and
reproduced the problem on their 3.0.something kernel.

>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
>=20
> I currently have 11 igb patches on that tree (which I recently
> submitted) that are not in Dave's tree yet.
>=20
> There have been a number of cleanup's recently, so while this is not
> expected, I am not surprised at the same time since I am in the middl=
e
> of the update to igb.
>=20
> We have not seen this on my local tree (which has the 11 patches plus
> 4-5 more patches for igb).  Almost all of them are
> cleanup's/re-organizing of igb, so nothing specific to the issue you
> have seen.

Thanks
