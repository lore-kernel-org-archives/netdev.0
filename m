From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] igb: restore EEPROM 16kB access limit
Date: Wed, 27 Apr 2011 10:15:42 -0400
Message-ID: <20110427141542.GB21309@gospo.rdu.redhat.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
	<EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
	<4D9F6A44.7060809@kpanic.de>
	<EDC0E76513226749BFBC9C3FB031318F0137E85E47@orsmsx508.amr.corp.intel.com>
	<20110426150659.GA21309@gospo.rdu.redhat.com>
	<EDC0E76513226749BFBC9C3FB031318F016AF39010@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stefan Assmann <sassmann@kpanic.de>, "Ronciak,
	John" <john.ronciak@intel.com>, Andy Gospodarek <andy@greyhouse.net>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016AF39010@orsmsx508.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2011 at 08:12:20AM -0700, Wyborny, Carolyn wrote:
[...]
> Part of the problem you are seeing is an apparently widespread EEPROM problem where the size word in the EEPROM is invalid.  Since we didn't really check it before it didn't cause a problem.  I have a patch coming that addresses this by messaging the user that the size is invalid but setting it to a default and continuing.  
> 

It wasn't really a problem for me until the commit Stefan mentioned
4322e561a93ec7ee034b603a6c610e7be90d4e8a was applied.

I'm glad you are planning a fix for it, but I hope it can be out soon
and not held up for too long by other patches planned for the next
update.


------------------------------------------------------------------------------
WhatsUp Gold - Download Free Network Management Software
The most intuitive, comprehensive, and cost-effective network 
management toolset available today.  Delivers lowest initial 
acquisition cost and overall TCO of any competing solution.
http://p.sf.net/sfu/whatsupgold-sd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
