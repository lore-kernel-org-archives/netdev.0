From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03788) Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Wed, 31 Jan 2007 14:14:08 +0900 (JST)
Message-ID: <20070131.141408.22662891.yoshfuji@linux-ipv6.org>
References: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
	<1172119906.2658.4.camel@LINE>
	<20070131.140914.105443849.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org, davem@davemloft.net,
        yoshfuji@linux-ipv6.org
To: weid@np.css.fujitsu.com
Return-path: <usagi-users-admin@linux-ipv6.org>
In-Reply-To: <20070131.140914.105443849.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

In article <20070131.140914.105443849.yoshfuji@linux-ipv6.org> (at Wed, 31 Jan 2007 14:09:14 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <1172119906.2658.4.camel@LINE> (at Wed, 21 Feb 2007 23:51:45 -0500), weidong <weid@np.css.fujitsu.com> says:
> 
> > 	Thanks for your patch. I think maybe we checking oif first is better,
> > and WARN_ON in function rt6_score_route().
> 
> Please remove WARN_ON.  Otherwise, I'm fine with it.

Argh, no.... wrong.

--yoshfuji
