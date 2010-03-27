From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] benet: Fix compile warnnings in
 drivers/net/benet/be_ethtool.c
Date: Sat, 27 Mar 2010 08:32:19 -0700 (PDT)
Message-ID: <20100327.083219.104064186.davem@davemloft.net>
References: <20100326061259.GB30341@localhost.localdomain>
	<20100326171616.GA20879@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wzt.wzt@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-drivers@serverengines.com,
	sathyap@serverengines.com
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100326171616.GA20879@serverengines.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Fri, 26 Mar 2010 22:46:18 +0530

> On 26/03/10 14:12 +0800, wzt.wzt@gmail.com wrote:
>> Fix the following warnings:
>> 
>> be_ethtool.c:493: warning: integer constant is too large for 'long' type
>> be_ethtool.c:493: warning: integer constant is too large for 'long' type
>> 
>> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
> 
> I would suggest using be2net instead of benet during the commit. 
> be2net: Fix compile warnnings in drivers/net/benet/be_ethtool.c
> 
> Acked-by: Ajit Khaparde <ajitk@serverengines.com>

Well, you cannot be surprised that people will use "benet"
since that is the name of the directory the driver lives
under.  It is not even referred to as "be2net" in the
MAINTAINERS entry.

I'm applying this fix as-is.
