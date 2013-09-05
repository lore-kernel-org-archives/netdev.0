From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: Re: [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Thu, 5 Sep 2013 17:53:38 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C6249AD@FMSMSX102.amr.corp.intel.com>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, September 04, 2013 5:38 PM

[...]

> Also, anything in sysfs is device specific and you really need to make
> a strong case for why your device is special and needs an exception.
> Other devices will have hardware switches and doing something through
> sysfs is going to create a pain for any controller application.
> 
> I vote against including the sysfs VEB stuff because it will become
> a lifetime ABI.

If we simply remove the VEB attributes (cvlan, mode, seid, svlan) but keep the model structure and the VSI attributes, will that satisfy your vote, or are you suggesting that we should drop the whole sysfs model that we implemented?

At this point after some discussion internally, we think it would be better to simply remove the whole sysfs module - it is an optional section with no direct operational requirement.  The intent was to get something started that looked useful, but perhaps we were a little premature in presenting this model for these new switch offload capabilities.

As Dave rightly pointed out, we may want to bring this back in the future, but I think that we have more work to do with the community in proposing and designing a switching model, if it really is even needed.  That's not an over-night thing, and we shouldn't be trying to patch up something that has fundamental concerns.  Also, bringing it back later when it isn't obscured by the rest of the driver might be more successful in getting community input.

sln



------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
