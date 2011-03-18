From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 28/36] net,rcu: convert call_rcu(phonet_device_rcu_free) to kfree_rcu()
Date: Fri, 18 Mar 2011 10:27:25 +0200
Message-ID: <201103181027.25735.remi.denis-courmont@nokia.com>
References: <4D82DADF.4010802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ext Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:62563 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630Ab1CRI1m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 04:27:42 -0400
In-Reply-To: <4D82DADF.4010802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 March 2011 06:09:03 ext Lai Jiangshan, you wrote:
> The rcu callback phonet_device_rcu_free() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(phonet_device_rcu_free)=
=2E
>=20
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

In principles, that's fine with me. But I think David is not taking tha=
t kind=20
of not-a-fix patch at the moment...

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
