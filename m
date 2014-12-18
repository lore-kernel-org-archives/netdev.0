From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Thu, 18 Dec 2014 18:23:08 +0100
Message-ID: <54930D7C.3000901@users.sourceforge.net>
References: <548B0A29.8050503@users.sourceforge.net>	<20141212.105106.1162681032492664308.davem@davemloft.net>	<548B1E44.6050005@users.sourceforge.net> <20141212.115922.687789059853236747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20141212.115922.687789059853236747.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Where should "the error pointers" be stored instead?
> 
> A local variable, before you assign it into the datastructure.

I have looked at the affected software infrastructure once more.
Now I find still that your data reorgansisation wish can not be resolved
in a simple way.

I imagine that your update suggestion would mean that the corresponding
pointers will be passed around by function parameters instead,
wouldn't it?

Two pointers were stored as the members "arc4" and "sha1" of the
data structure "ppp_mppe_state" for a specific reason. A pointer to
this structure is passed to the ppp_register_compressor() function.
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/include/linux/ppp-comp.h?id=607ca46e97a1b6594b29647d98a32d545c24bdff#n32

The data structure "compressor" manages some function pointers.
I assume that this interface should not be changed at the moment, should it?

Are further ideas needed here?

Regards,
Markus
