From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next 0/3] dev_disable_lro() improvements for stacked
 devices
Date: Wed, 12 Nov 2014 14:15:46 +0100
Message-ID: <20141112131546.GA8745@unicorn.suse.cz>
References: <cover.1415692212.git.mkubecek@suse.cz>
 <20141111090522.GB20586@raspberrypi>
 <20141111093457.GA30178@unicorn.suse.cz>
 <20141111.214752.266800170368088905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
	andy@greyhouse.net, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141111.214752.266800170368088905.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 09:47:52PM -0500, David Miller wrote:
> 
> Please do it generically.
> 
> Having a special stanza for each layered device type in
> dev_disable_lro() is beyond stupid.  Especially when it
> can in fact be done cleanly.

I gave it some thought and I would like ask one question first:

Does the upper-lower relationship always mean that upper device receives
packets through its lower device(s) so that LRO should always be
disabled for lower devices whenever there are some? Or should it be
limited only to an explicit list of device types (vlan, macvlan, bond,
team)?

                                                         Michal Kubecek
