From: David Miller <davem@davemloft.net>
Subject: Re: bonding: cannot remove certain named devices
Date: Thu, 17 Aug 2006 18:01:19 -0700 (PDT)
Message-ID: <20060817.180119.74753683.davem@davemloft.net>
References: <1155799783.7566.5.camel@capoeira>
	<20060817.162340.74748342.davem@davemloft.net>
	<1155861283.15195.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xavier.bestel@free.fr, 7eggert@gmx.de, notting@redhat.com,
	cate@debian.org, 7eggert@elstempel.de, shemminger@osdl.org,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932180AbWHRBBM@vger.kernel.org>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1155861283.15195.112.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 18 Aug 2006 01:34:43 +0100

> Ar Iau, 2006-08-17 am 16:23 -0700, ysgrifennodd David Miller:
> > All you "name purists", go rename the block device name that is used
> > for your root partition to something with a space in it
> 
> Works fine. It doesn't work fine for non root volumes (except by label)
> because of the fstab format but root is ok !

Check out how your root device would be fsck'd.  The command line run
by the /etc/init* scripts either doesn't quote the device argument or
it consults fstab which as you said has limitations when dealing with
spaces.

It's either going to do something like $device (this is what debian
derived systems do), unquoted, or it will do "fsck -A" which runs into
said fstab format limitations (which is what fedora does).

Either way the point is that this issue is scattered all over the
place.

Preventing spaces in the name doesn't prevent the use of names in non-
romanized languages any moreso than preventing ".", "..", and "/"
already does.
