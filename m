From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Off-by-one bug at unix_mkname ?
Date: Mon, 28 Mar 2005 18:33:31 +0900 (JST)
Message-ID: <20050328.183331.119479139.yoshfuji@linux-ipv6.org>
References: <20050328.172108.30349253.yoshfuji@linux-ipv6.org>
	<20050328.173938.26746686.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.61.0503281124450.18443@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, from-linux-kernel@I-love.sakura.ne.jp,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261393AbVC1Jbj@vger.kernel.org>
To: jengelh@linux01.gwdg.de
In-Reply-To: <Pine.LNX.4.61.0503281124450.18443@yvahk01.tjqt.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.61.0503281124450.18443@yvahk01.tjqt.qr> (at Mon, 28 Mar 2005 11:25:39 +0200 (MEST)), Jan Engelhardt <jengelh@linux01.gwdg.de> says:

> 
> On Mar 28 2005 17:39, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> 
> >+		 *	This may look like an off by one error but it is
> >+		 *	a bit more subtle. 108 is the longest valid AF_UNIX
> >+		 *	path for a binding. sun_path[108] doesnt as such
> >+		 *	exist. However in kernel space we are guaranteed that
> >+		 *	it is a valid memory location in our kernel
> >+		 *	address buffer.
> >+		 */
> 
> Now, does 2.6. _still_ guarantee that 108 is a valid offset?

Yes, it does.

--yoshfuji
