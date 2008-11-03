From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC/PATCH] e100 driver didn't support any
	MII-less PHYs...
Date: Mon, 3 Nov 2008 01:34:06 -0800
Message-ID: <9929d2390811030134ybe1d8aaq43b5a533f73fee71@mail.gmail.com>
References: <20071228235118.GA31059@rhlx01.hs-esslingen.de>
	<477732A5.5020501@intel.com>
	<20080101200908.GA14805@rhlx01.hs-esslingen.de>
	<20080129230315.GA13389@rhlx01.hs-esslingen.de>
	<479FB225.7090604@intel.com>
	<20080130064909.GA19793@rhlx01.hs-esslingen.de>
	<47A0A713.7030304@intel.com>
	<20081103080430.GA32459@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Kok,
	Auke" <auke-jan.h.kok@intel.com>, bunk@kernel.org,
	linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081103080430.GA32459@rhlx01.hs-esslingen.de>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Nov 3, 2008 at 12:04 AM, Andreas Mohr
<andim2@users.sourceforge.net> wrote:
> Hi,
>
> On Wed, Jan 30, 2008 at 08:34:27AM -0800, Kok, Auke wrote:
>> Andreas Mohr wrote:
>> > Hi,
>> >
>> > On Tue, Jan 29, 2008 at 03:09:25PM -0800, Kok, Auke wrote:
>> >> Andreas Mohr wrote:
>> >>> Perhaps it's useful to file a bug/patch
>> >>> on http://sourceforge.net/projects/e1000/ ? Perhaps -mm testing?
>> >> I wanted to push this though our testing labs first which has not happened due to
>> >> time constraints - that should quickly at least confirm that the most common nics
>> >> work OK after the change with your patch. I'll try and see if we can get this
>> >> testing done soon.
>> >
>> > Oh, full-scale regression testing even? Nice idea...
>> > Would optionally be even better if during hardware tests one could also
>> > dig out some i82503-based card (or additional MII-less cards?)
>> > since I didn't really make any effort yet to try to make them all
>> > recognized/supported by my patch already (would have been out of scope anyway
>> > since I have this single card only).
>>
>> the problem is that I think that most of those (mii-less cards) are customly
>> designed by OEM's that buy the silicon and glue on a different interface and we
>> usually do not carry those designs in our labs apart from a few exceptions. So, I
>> can at least touch the common hardware in testing, but not the exotic stuff.
>
> Any update on how to get this support in? (it's not available in 2.6.28-rc2)
>
> As it stands, I'm not the only one who would need this...
>
> Thanks!
>
> Andreas Mohr
> --
>

I have a patch from Auke, which deals with the MII-less PHY's in e100.
 I will check on the status of the patch and either let you know the
status or will be submitting a patch soon to netdev to address this
issue.

-- 
Cheers,
Jeff

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
