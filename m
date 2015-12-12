From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linux-next] iwl_mvm_get_key_sta_id() suspicious RCU usage
Date: Sat, 12 Dec 2015 09:11:40 +0900
Message-ID: <20151212001140.GB579@swordfish>
References: <20151211134418.GA29351@swordfish>
 <1449841741.2324.2.camel@sipsolutions.net>
 <20151212000501.GA579@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151212000501.GA579@swordfish>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/12/15 09:05), Sergey Senozhatsky wrote:
> On (12/11/15 14:49), Johannes Berg wrote:
> > On Fri, 2015-12-11 at 22:44 +0900, Sergey Senozhatsky wrote:
> > 
> > > [ 6385.246300] drivers/net/wireless/intel/iwlwifi/mvm/sta.c:1226
> > > suspicious rcu_dereference_protected() usage!
> > > 
> > 
> > Funny, Laura Abbott also reported this bug earlier today :)
> > 
> > I've sent out a fix, you can see it here:
> > https://patchwork.ozlabs.org/patch/555587/
> > 
> 

had to replace 'drivers/net/wireless/iwlwifi/mvm/sta.c' with
drivers/net/wireless/intel/iwlwifi/mvm/sta.c'

I'll report back if any problems show up.

	-ss
