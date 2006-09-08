From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Fri, 08 Sep 2006 21:52:33 +0200
Message-ID: <4501CA01.3050904@trash.net>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:30093 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751120AbWIHTwO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 15:52:14 -0400
To: Gnome42 Gnome42 <gnome42@gmail.com>
In-Reply-To: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gnome42 Gnome42 wrote:
> IPSec got broken in 2.6.18-rc4-mm3+, 2.6.18-rc4-mm2 works and
> 2.6.18-rc5 also works.
> 
> The tunnel looks like its established correctly in the racoon logs and
> the traffic is encrypted on the wire. However, the other side does not
> decrypt the traffic it just seems to disappear.

Can you see the decrypted packets on the incoming interface on the
other side?

> I have confirmed this problem exists between two linux boxen and a
> Netopia router as well.
> 
> The git-net.patch increased in size by about 50% between
> 2.6.18-rc4-mm2 and 2.6.18-rc4-mm3 (likely suspect?), but i was unable
> to simply patch -R it cleanly.
> 
> Suggestions?

Please post your policies and related SAs from both sides.
Are you using NAT, iptables or anything like that?

