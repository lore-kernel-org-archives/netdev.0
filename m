From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH][v2] Netfilter Kconfig: Expose IPv4/6 connection
 tracking options by selecting NF_CONNTRACK_ENABLED
Date: Thu, 26 Jul 2007 10:18:22 +0900 (JST)
Message-ID: <200707260118.l6Q1INsb011889@toshiba.co.jp>
References: <200707251802.22200.a1426z@gawab.com>
	<46A7EECD.9070801@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a1426z@gawab.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, sam@ravnborg.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:58086 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbXGZBs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 21:48:27 -0400
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id l6Q1mO6K023350
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 10:48:25 +0900 (JST)
Received: from tsb-wall.toshiba.co.jp ([133.199.160.134])
	by inet-tsb5.toshiba.co.jp  with ESMTP id l6Q1IPDC017462
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 10:18:25 +0900 (JST)
Received: (from root@localhost)
	by tsb-wall.toshiba.co.jp  id l6Q1IOMQ004793
	for netdev@vger.kernel.org; Thu, 26 Jul 2007 10:18:24 +0900 (JST)
Received: from mx.toshiba.co.jp (localhost [127.0.0.1])
	by ovp1.toshiba.co.jp  with ESMTP id l6Q1IOGX001312
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 10:18:24 +0900 (JST)
In-Reply-To: <46A7EECD.9070801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 26 Jul 2007 02:46:05 +0200

> [Removed a few CCs]
> 
> Al Boldi wrote:
> > Make NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6 select NF_CONNTRACK_ENABLED.
> 
> 
> One thought that occured to me after the last of many false bugreports
> that were actually caused by failure to configure the new options
> properly. Most people know they want NF_CONNTRACK (and its selected by
> default with old configs), what they're missing is that they now also
> need to select IPv4 connection tracking. So what would really make sense
> is to make NF_CONNTRACK_IPV4 default to "m" (and really *everyone*
> using conntrack wants this). But with your proposed change this would
> default to selecting NF_CONNTRACK by default, which I'm not so sure
> is a good idea. So I'm leaning towards just using "m" as default for
> IPv4 conntrack to save people trouble and myself some bugreports, but
> I also like your simplification ...
> 
> Maybe we can do something to have the NF_CONNTRACK_ENABLED option select
> NF_CONNTRACK_IPV4 (which really is what we actually want) and combine
> that with automatic selection of NF_CONNTRACK? I believe the only case
> with negative impact would be people that currently use only IPv6
> connection tracking, which is most likely nobody.

I agree. I've not heard trouble with NF_CONNTRACK_IPV6. I think that is
because it is purely new feature.

BTW, it's too late to restore IP_NF_CONNTRACK in stable and current tree
for a while ?

-- Yasuyuki Kozakai
