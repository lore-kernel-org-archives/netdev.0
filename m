From: David Miller <davem@davemloft.net>
Subject: Re: r8169 on 3.8.13, 3.9.2, 3.10-rc1, was Re: [ 00/73]
 3.8.13-stable review
Date: Wed, 15 May 2013 13:39:13 -0700 (PDT)
Message-ID: <20130515.133913.339696465413205791.davem@davemloft.net>
References: <pan.2013.05.10.10.54.26.943195@googlemail.com>
	<20130515000715.GA20099@milliways>
	<20130515061401.GA4382@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zarniwhoop@ntlworld.com, holger.hoffstaette@googlemail.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130515061401.GA4382@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 15 May 2013 08:14:01 +0200

> Ken Moffat <zarniwhoop@ntlworld.com> :
> [...]
>>  Cc'ing to netdev because I don't think this has had a response, and
> 
> A patch has been sent to netdev a few hours ago. It needs more work,
> especially testing (hint, hint) as I don't have a proven test case yet.
> 
> Please note:
> - if you don't use a 8168evl (check your dmesg for the XID line emitted
>   by the r8169 driver), you are not the experiencing the same bug.
> - if you don't enable Tx checksum offload (distro/vendor dependent though
>   disabled by default in the vanilla driver, see ethtool -k eth0,
>   ethtool -K eth0 tx on sg on)), you are not the experiencing the same
>   bug.
> - if you are experiencing the same bug, 3.10-rc1 should work again
>   after reverting e5195c1f31f399289347e043d6abf3ffa80f0005
> 
> If someone comes with a failing network capture and a working one, it will
> save time. A 64 bytes (max) packet is not correctly transmitted.

FWIW, I was about to submit the regression causing commit to -stable
but now I'm going to hold off until we get the fix for it to Linus.
