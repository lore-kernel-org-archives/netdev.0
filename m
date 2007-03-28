From: David Miller <davem@davemloft.net>
Subject: Re: IPv6: Connection reset/timeout under heavy load
Date: Wed, 28 Mar 2007 02:26:24 -0700 (PDT)
Message-ID: <20070328.022624.59656162.davem@davemloft.net>
References: <20070327.194636.63219035.yoshfuji@linux-ipv6.org>
	<460A2BDB.6080200@ripe.net>
	<20070328.182334.109744556.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: agoston@ripe.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965418AbXC1J0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 05:26:25 -0400
In-Reply-To: <20070328.182334.109744556.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 28 Mar 2007 18:23:34 +0900 (JST)

> In article <460A2BDB.6080200@ripe.net> (at Wed, 28 Mar 2007 10:48:27 +0200), Agoston Horvath <agoston@ripe.net> says:
> 
> > YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > > Would you test with latest kernel, if possible, please?
> > 
> > For the archive: switching to 2.6.20.4 fixed this problem.
> 
> Thank you for your report.
> 
> I guess the following change will fix the issue for 2.6.16.y:
> http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/yoshfuji/linux-2.6-fix.git;a=commit;h=33a79bba0cc2f197b46cc54182f94c31ff6ad334
> 
> I hope this patch will go in 2.6.16-stable...

Please forward this patch to Adrian Bunk (bunk@stusta.de),
he will definitely add it to 2.6.16-stable for you.
