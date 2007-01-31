From: David Miller <davem@davemloft.net>
Subject: (usagi-users 03790) Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Tue, 30 Jan 2007 21:46:19 -0800 (PST)
Message-ID: <20070130.214619.74747768.davem@davemloft.net>
References: <20070131.140914.105443849.yoshfuji@linux-ipv6.org>
	<20070131.141408.22662891.yoshfuji@linux-ipv6.org>
	<20070131.144250.58478716.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
        weid@np.css.fujitsu.com
To: yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
In-Reply-To: <20070131.144250.58478716.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 31 Jan 2007 14:42:50 +0900 (JST)

> In article <20070131.141408.22662891.yoshfuji@linux-ipv6.org> (at Wed, 31 Jan 2007 14:14:08 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > In article <20070131.140914.105443849.yoshfuji@linux-ipv6.org> (at Wed, 31 Jan 2007 14:09:14 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> > 
> > > In article <1172119906.2658.4.camel@LINE> (at Wed, 21 Feb 2007 23:51:45 -0500), weidong <weid@np.css.fujitsu.com> says:
> > > 
> > > > 	Thanks for your patch. I think maybe we checking oif first is better,
> > > > and WARN_ON in function rt6_score_route().
> > > 
> > > Please remove WARN_ON.  Otherwise, I'm fine with it.
> > 
> > Argh, no.... wrong.
> 
> Here's updated patch, intented for net-2.6.21.  Dave?

I'll integrate this after I work on some net-2.6.20
bug fixes I want to complete today.
