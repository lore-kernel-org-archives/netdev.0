From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ethtool-3] add ixgb dump register support
Date: Tue, 22 Mar 2005 18:45:27 -0500
Message-ID: <4240AE17.2030706@pobox.com>
References: <Pine.LNX.4.44.0503111634500.24631-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.44.0503111634500.24631-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> I didn't to a push to gkernel bitkeeper because I've never done that
> before, Jeff if you want that, I can try it.
> 
> This is off a bitkeeper clone from yesterday.
> 
> Apologies if I screwed up something with bitkeeper, as I'm just figuring
> it all out but want to learn!

Sorry for taking so long to get to this.  Applied your patch just fine, 
you did everything right.

If you wish to submit via BitKeeper, the model (for ethtool, the kernel, 
whatever) is as follows:

1) Clone your own repository (usually at bkbits.net).  Let's call it 
jesse.bkbits.net/ethtool.

2) Check in changes to a local (on your workstation) clone of ethtool.

3) 'bk push" to jesse.bkbits.net/ethtool

4) Use Docuementation/BK-usage/bk-make-sum script in kernel tree to 
create a summary of your changes:

	cd /work/repo/ethtool-jesse
	bk-make-sum ../ethtool-vanilla
	mv /tmp/linus.txt my-submission.txt
	gcapatch >> my-submission.txt

NOTE: gcapatch (also in BK-usage subdir) must be modified slightly, to 
change an embedded URL, before it can be used with ethtool.

5) Email my-submission.txt to jgarzik@pobox.com and netdev@oss.sgi.com.

6) I receive the email, and do a 'bk pull bk://jesse.bkbits.net/ethtool' 
to incorporate your changes into my local tree.

7) I do a 'bk push' to push the changes into bk://gkernel.bkbits.net/ethtool


So as you can see, given BitKeeper's highly distributed model, there is 
no concept of "a bunch of people have permission to push to the tree." 
It's a pull model, not a push model.

	Jeff
