From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net 0/2] net/ethtool, mlx4_en: RSS hash function setting
 fixes
Date: Mon, 27 Apr 2015 13:34:57 +0300
Message-ID: <553E10D1.5050505@mellanox.com>
References: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
 <20150426.230208.609174325391847955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0096.outbound.protection.outlook.com ([157.55.234.96]:28154
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751252AbbD0KvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 06:51:14 -0400
In-Reply-To: <20150426.230208.609174325391847955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/2015 6:02 AM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Sun, 26 Apr 2015 17:36:04 +0300
> 
>> Hash function is represented as an eight bit field, every bit represents a
>> function.  Currently possible values are: 1 for Toeplitz and 2 for XOR.
>> This commit changes the representation from bit flags into a value. Because
>> only one hash function will be used at a time, there is no sense using bit
>> flags for it.
> 
> If we ever want to add some kind of control attributes that might
> apply to any hash, we'll want flags again.
> 
> You can just enforce that only one of these hash function bits can be
> set at one time, and be done with it.
> 
Ok, re-spinning with the fix to mlx4_en only.
