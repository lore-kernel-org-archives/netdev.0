From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: Re: [net-next v2 1/8] i40e: main driver core
Date: Tue, 27 Aug 2013 20:34:04 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C617400@FMSMSX102.amr.corp.intel.com>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377224142-25160-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130823.002805.1975660490102085087.davem@davemloft.net>
	<FC41C24E35F18A40888AACA1A36F3E416C615C3B@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>, David Miller
	<davem@davemloft.net>, "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E416C615C3B@FMSMSX102.amr.corp.intel.com>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 23, 2013 12:28 AM

[...]

>
> > +{
> > +	int i;
> > +	struct i40e_pf *pf = vsi->back;
>
> Please order local variable declarations from longest line to shortest.

I understand the aesthetics as it does make the code look a little cleaner, and we can do this with a lot of our functions.  However, there are several instances where one declaration initialization depends on a previous declaration, and trying to organize by line length breaks these relationships.  Do you mind if we're not perfect on following this one?

Also, perhaps I haven't watched closely enough, but I don't remember seeing this comment on other code.  Is this a new recommendation that will be going into the CodingStyle document?

Thanks,
sln


------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
