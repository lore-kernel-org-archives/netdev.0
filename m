From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH v3 1/2] e1000e: Only disable ASPM
	on	82573L devices
Date: Fri, 19 Feb 2010 22:03:06 +0000
Message-ID: <20100219220306.GA6795@srcf.ucam.org>
References: <1265912094-4705-1-git-send-email-mjg@redhat.com>
	<8DD2590731AB5D4C9DBF71A877482A9061394282@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9061394282@orsmsx509.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Feb 19, 2010 at 01:53:01PM -0800, Allan, Bruce W wrote:

> Exactly which erratum are you referring to?  Erratum 17 in the 82573 
> Specification Update?  If that is the case, I see the possibility of 
> another interpretation of the erratum which suggests the possibility 
> of the same issue on other variants of the 82573 when using standard 
> frame sizes and ASPM enabled.  Not to mention, I believe there may be 
> other parts (82574 perhaps) that will have issues with L1 ASPM 
> enabled.  I will follow-up with the folks who did the investigation 
> that resulted in the erratum in order to get a clearer picture of all 
> this, and take a look into other parts that may likewise be affected.

Ah, yes - I see that it could be interpreted that way. The description 
seems to suggest that it's only relevant if ERT is enabled, which is 
required for jumbo frames. I'm not entirely clear on whether ERT is 
enabled in other circumstances? If not, we ought to be able to limit 
this to the L device - if not, it should be done on E and V as well.

The 82574 specification update doesn't mention any ASPM errata, but if 
you're able to check then that would be great. My main aim here is to 
try to get it turned back on on hardware where this works, since it's a 
measurable power saving.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
