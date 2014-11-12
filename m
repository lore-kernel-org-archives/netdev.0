From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] dev_disable_lro() improvements for
 stacked devices
Date: Wed, 12 Nov 2014 15:08:28 -0500 (EST)
Message-ID: <20141112.150828.421966825872572028.davem@davemloft.net>
References: <20141111093457.GA30178@unicorn.suse.cz>
	<20141111.214752.266800170368088905.davem@davemloft.net>
	<20141112131546.GA8745@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
	andy@greyhouse.net, jiri@resnulli.us
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141112131546.GA8745@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Wed, 12 Nov 2014 14:15:46 +0100

> On Tue, Nov 11, 2014 at 09:47:52PM -0500, David Miller wrote:
>> 
>> Please do it generically.
>> 
>> Having a special stanza for each layered device type in
>> dev_disable_lro() is beyond stupid.  Especially when it
>> can in fact be done cleanly.
> 
> I gave it some thought and I would like ask one question first:
> 
> Does the upper-lower relationship always mean that upper device receives
> packets through its lower device(s) so that LRO should always be
> disabled for lower devices whenever there are some? Or should it be
> limited only to an explicit list of device types (vlan, macvlan, bond,
> team)?

This should be the case, anyone else?
