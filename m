From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH][RFC] cxgb4: Not need to hold the adap_rcu_lock lock when read adap_rcu_list
Date: Tue, 24 Jun 2014 15:56:08 -0700
Message-ID: <23154267-C121-4451-9BA8-25BD9387047F@chelsio.com>
References: <1403256756-6557-1-git-send-email-rongqing.li@windriver.com> <20140624.155410.802407476153586247.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rongqing.li@windriver.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, hariprasad@chelsio.com,
	greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43529
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751479AbaFXW4N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 18:56:13 -0400
In-Reply-To: <20140624.155410.802407476153586247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 24, 2014, at 3:54 PM, David Miller <davem@davemloft.net> wrote:

> From: <rongqing.li@windriver.com>
> Date: Fri, 20 Jun 2014 17:32:36 +0800
>=20
>> From: Li RongQing <roy.qing.li@gmail.com>=20
>>=20
>> cxgb4_netdev maybe lead to dead lock, since it uses a spin lock, and=
 be called
>> in both thread and softirq context, but not disable BH, the lockdep =
report is
>> below; In fact, cxgb4_netdev only reads adap_rcu_list with RCU prote=
ction, so
>> not need to hold spin lock again.
> ...
>> Reported-by: Ben Greear <greearb@candelatech.com>
>> Cc: Casey Leedom <leedom@chelsio.com>
>> Cc: Hariprasad Shenai <hariprasad@chelsio.com>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks.
>=20
> Casey please _do not_ put indentation in front of your Acked-by:,
> automated tools like patchwork will not pick it up if you do that.
>=20
> I'm actually very surprised how much spurious indentation and weird
> spacing shows up in some people's postings.  You folks definitely are
> using graphical tools to type this stuff in, rather than real pure
> text editors.

  Sorry, that was 100% my fault.  I actually typed it in that way becau=
se I didn=92t know.  My Bad and I=92ll do better next time.

Casey