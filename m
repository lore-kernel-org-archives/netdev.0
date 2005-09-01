From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netdevice reference leak in af_ax25.c ??
Date: Thu, 01 Sep 2005 20:56:19 +0200
Message-ID: <43174ED3.6040106@trash.net>
References: <43174B67.9030109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <43174B67.9030109@candelatech.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> 
> I believe the SO_BINDTODEVICE case in net/ax25/af_x25.c  (line 613 or so)
> leaks a reference to a net device.  It does a dev_get_by_name,
> which holds a reference, but since it never assigns the pointer
> anywhere, I do not see how it can ever free it later.
> 
> Please clue me in as to where it's released if it actually is.

I can't find the code you're talking about, there's no dev_get* in my
version of af_x25.c. Please paste the code you're talking about in
your bugreports, thanks.
