From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 00:07:07 +0200
Message-ID: <4A19C50B.9040304@cosmosbay.com>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34109 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbZEXWHQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 18:07:16 -0400
In-Reply-To: <20090524214433.GH24757@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Sun, May 24, 2009 at 11:42:17PM +0200, Eric Dumazet wrote:
>> (But vlan case might be litle bit more expensive than your case, sin=
ce we call
>> synchronize_net() three times (once in unregister_vlan_dev(), and tw=
ice in rollback_registered()
>=20
> I did try commenting out the synchronize_net() calls in rollback_regi=
stered(),=20
> but that had almost no effect on the rate of interface deletion.  50m=
s is=20
> still way too expensive.
>=20
> 		-ben

Maybe your HZ is too low ? Changing to 1000 HZ helps a lot

Also your hotplug config might do strange things at device removal ?

What distro do you use ?

