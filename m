From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: fix registration order of driver and DCA
 nofitication
Date: Wed, 03 Apr 2013 23:25:18 -0400 (EDT)
Message-ID: <20130403.232518.1885732115120797753.davem@davemloft.net>
References: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1365045072.5248.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jakub.kicinski@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: joe@perches.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1365045072.5248.1.camel@joe-AO722>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 03 Apr 2013 20:11:12 -0700

> On Wed, 2013-04-03 at 19:50 -0700, Jeff Kirsher wrote:
>> From: Jakub Kicinski <jakub.kicinski@intel.com>
>> 
>> ixgbe_notify_dca cannot be called before driver registration
>> because it expects driver's klist_devices to be allocated and
>> initialized. While on it make sure debugfs files are removed
>> when registration fails.
> 
> Why not take out a bunch of these #ifdef CONFIG_DEBUG_FS at
> the same time?  Something like:

Because it's a bug fix targetted at 'net' and thus must be a minimal
fix rather than something targetted at 'net-next' where we could do
cleanups like that.
