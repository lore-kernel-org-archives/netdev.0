From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000: Fix DMA mapping error handling
	on TX
Date: Sat, 23 Jan 2010 19:58:07 -0800
Message-ID: <9929d2391001231958n3f8d5165yaeed9ec1e0d7121a@mail.gmail.com>
References: <20100121114244.GC32259@kryten>
	<9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>
	<20100124004753.GB2996@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yi Zou <yi.zou@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Roel Kluin <roel.kluin@gmail.com>
To: Anton Blanchard <anton@samba.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100124004753.GB2996@kryten>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, Jan 23, 2010 at 16:47, Anton Blanchard <anton@samba.org> wrote:
>
> Hi,
>
>> This patch does not apply to the current e1000 driver in net-2.6, much
>> of this patch has already been corrected (applied) by Roel Kluin
>> recent patch.
>
> Sorry I was basing off net-next. I just compared it to my fix and looks like
> the patch in net-2.6 has an off by one error doesn't it?
>
> Anton
>
> --
>

This was discussed during our code review of Roel's patch, and it was
found that there was not an issue.  But I will review the code again
to ensure that there is not "an off by one error".  Thanks for looking
at this.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
