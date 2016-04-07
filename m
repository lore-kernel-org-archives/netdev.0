From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 194/196] include/net/sock.h:1367:9: error:
 implicit declaration of function 'lockdep_is_held'
Date: Thu, 07 Apr 2016 17:09:37 -0400 (EDT)
Message-ID: <20160407.170937.292677537698351913.davem@davemloft.net>
References: <201604080541.jzrX1awl%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kbuild-all@01.org,
	netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcDGVJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 17:09:39 -0400
In-Reply-To: <201604080541.jzrX1awl%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Fri, 8 Apr 2016 05:00:42 +0800

>    include/net/sock.h: In function 'lockdep_sock_is_held':
>>> include/net/sock.h:1367:9: error: implicit declaration of function 'lockdep_is_held' [-Werror=implicit-function-declaration]
>      return lockdep_is_held(&sk->sk_lock) ||
...
>   1361	} while (0)
>   1362	
>   1363	static bool lockdep_sock_is_held(const struct sock *csk)
>   1364	{
>   1365		struct sock *sk = (struct sock *)csk;
>   1366	
>> 1367		return lockdep_is_held(&sk->sk_lock) ||
>   1368		       lockdep_is_held(&sk->sk_lock.slock);
>   1369	}

Hmmm, Hannes to we need to make this a macro just like lockdep_is_held() is?
