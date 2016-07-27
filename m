From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out
 systim	sanitization
Date: Wed, 27 Jul 2016 11:01:55 -0400
Message-ID: <20160727150155.GF36313@redhat.com>
References: <1469292274-59237-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-2-git-send-email-jarod@redhat.com>
 <8F4C390AFA9F4444A4AA77F4A3BEC78A190E7843@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Hall, Christopher S" <christopher.s.hall@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Avargil, Raanan" <raanan.avargil@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8F4C390AFA9F4444A4AA77F4A3BEC78A190E7843@HASMSX110.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 02:09:13PM +0000, Avargil, Raanan wrote:
>> This is prepatory work for an expanding list of adapter families that have occasional ~10 hour clock jumps when being used for PTP. Factor out the sanitization function and convert to using a feature (bug) flag, per suggestion from Jesse Brandeburg.
>> 
>> Littering functional code with device-specific checks is much messier than simply checking a flag, and having device-specific init set flags as needed.
>> There are probably a number of other cases in the e1000e code that could/should be converted similarly.
> 
> Looks ok to me.
> Adding Chris who asked what happens if we reach the max retry counter (E1000_MAX_82574_SYSTIM_REREAD)?
> This counter is set to 50. 
> Can you, for testing purposes, decreased this value (or even set it to 0) and see what happens?

Unfortunately, I don't have direct access to the affected hardware myself,
so I'd have to prep a test build, hand it off to someone and play relay. I
could do that, but it'd have some lag and possible multiple round-trips...
Anyone inside Intel have hardware handy to test on? :p

-- 
Jarod Wilson
jarod@redhat.com
