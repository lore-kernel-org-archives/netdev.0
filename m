From: "David S. Miller" <davem@redhat.com>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 12:10:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118.121047.99725598.davem@redhat.com>
References: <20021118195618.GA22603@outpost.ds9a.nl>
	<200211182004.XAA12908@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211182004.XAA12908@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Mon, 18 Nov 2002 23:04:47 +0300 (MSK)
   
   > I did turn on CONFIG_XFRM_USER, does it conflict with PF_KEY?
   
   Yes, their interaction is still... mmm... not polished.
   Build both xfrm_user and af_key as modules and load only one for now.
   
You added xfrm netlink support to libipsec?

If not, the only thing which should get in the way is that there
are two key managers registered but that should "just work" :)
