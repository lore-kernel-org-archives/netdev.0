From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 19:42:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AFAF4.3040604@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org>	<20030801132037.3f3542ae.davem@redhat.com>	<3F2AE91D.5090705@pobox.com>	<20030801153255.204baf66.davem@redhat.com>	<3F2AF141.2010308@pobox.com>	<20030801160136.3342c5cc.davem@redhat.com>	<3F2AF525.3000605@pobox.com> <20030801161937.1d9a7126.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801161937.1d9a7126.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 01 Aug 2003 19:17:57 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>Solution #2 chooses to create a tiny bit more 
>>merge-to-mainline pain, but also keeps the mainline kernel drivers more 
>>clean.
> 
> 
> You don't need DO_ETHTOOL_OPS and thus the merge-to-mainline pain
> at all if you do something like:
> 
> 1) SET_ETHDEV_OPS() also overrides the ->do_ioctl() setting to
>    a kcompat_netdev_ioctl() one, but remembers the original pointer
>    somewhere.
> 
> 2) kcompat_netdev_ioctl() does the things DO_ETHTOOL_OPS would
>    have done, failing that it calls the saved ->do_ioctl() pointer.


Certainly.  That's a bit nicer than the back-compat gunk I was plotting, 
even.

Still need the boring and obvious definition of SET_ETHTOOL_OPS in 
mainline, though.

	Jeff
