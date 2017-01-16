From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: marvell: skge: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 16 Jan 2017 12:36:17 -0500 (EST)
Message-ID: <20170116.123617.1891198374111644473.davem@davemloft.net>
References: <1484395708-4107-1-git-send-email-tremyfr@gmail.com>
        <20170116092951.3b577463@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, mlindner@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170116092951.3b577463@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 16 Jan 2017 09:29:51 -0800

> On Sat, 14 Jan 2017 13:08:28 +0100
> Philippe Reynes <tremyfr@gmail.com> wrote:
> 
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>> 
>> The callback set_link_ksettings no longer update the value
>> of advertising, as the struct ethtool_link_ksettings is
>> defined as const.
>> 
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> 
> Did you test this on real hardware?

Philippe probably doesn't have physical access to most of the
drivers he is converting.

But, he is the only person working on converting all of the drivers,
and therefore when the change looks straightforward I am going to
reward his work and effort by applying his changes and hope there
isn't any fallout.

Those who really care can test his patches and give a Tested-by:

Thanks.
