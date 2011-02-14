From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-02-14
Date: Mon, 14 Feb 2011 13:00:56 -0800 (PST)
Message-ID: <20110214.130056.115934219.davem@davemloft.net>
References: <20110214204406.GG2722@tuxdriver.com>
	<20110214.125148.59672184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110214.125148.59672184.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 14 Feb 2011 12:51:48 -0800 (PST)

> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 14 Feb 2011 15:44:06 -0500
> 
>> A handful of fixes intended for 2.6.38...
>> 
>> This includes a couple of bluetooth device IDs, a bluetooth one-liner
>> to avoid multiple connection responses, a locking fix to avoid some
>> log spam, and a patch to turn off PCLP health checking for iwl3945
>> (because the checking has not proven helpful and it kills performance).
>> 
>> Please let me know if there are problems!
> 
> Pulled, thanks John.

Please address this newly introduced warning in a future pull request,
thanks:

drivers/net/wireless/iwlwifi/iwl-3945.c:411:13: warning: 'iwl3945_good_plcp_health' defined but not used
