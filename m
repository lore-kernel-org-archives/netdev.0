From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: How to enable more than ~256 routing tables?
Date: Tue, 22 Apr 2003 16:16:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030422.161645.80924947.yoshfuji@linux-ipv6.org>
References: <3EA4EAFD.5020808@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EA4EAFD.5020808@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <3EA4EAFD.5020808@candelatech.com> (at Tue, 22 Apr 2003 00:10:53 -0700), Ben Greear <greearb@candelatech.com> says:

> Is it possible to just change the RT_TABLE_MAX to be higher and have 256-????
> be more /* User defined values */ ?

No. rtm_table in rtmsg{} is unsigned char.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
