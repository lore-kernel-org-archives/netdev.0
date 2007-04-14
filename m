From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 13 Apr 2007 18:49:47 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5202504EEE@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	e1000-devel@lists.sourceforge.net, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Adrian Bunk" <bunk@stusta.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> On Sat, 14 Apr 2007, Adrian Bunk wrote:
>> 
>> Subject    : laptops with e1000: lockups
>> References :
>> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603
>> Submitter  : Dave Jones <davej@redhat.com> 
>> Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Status     : problem is being debugged
>> 
>> Subject    : forcedeth: interface hangs under load
>> References : http://lkml.org/lkml/2007/4/3/39
>> Submitter  : Ingo Molnar <mingo@elte.hu>
>> Handled-By : Ingo Molnar <mingo@elte.hu>
>>              Ayaz Abdulla <aabdulla@nvidia.com>
>> Status     : problem is being debugged

Linus Torvalds wrote:
> It does seem networking related somehow. Yeah, it could be obviously
> be a combination of independent bugs both in e1000/ and forcedeth
> drivers, but maybe there is something in common here...
 
> So please people, give it a look. Comments?

I mentioned this in the bugzilla (229603 above), but we have at least
reproduced this here in our lab w.r.t e1000.  Some people were on
vacation this week so the issue didn't progress (regardless if this is
e1000 specific we will have some resources helping to report on this
next week).  So we're not sure if this is an e1000 problem yet.  More
soon, maybe I'll try to bisect back to some good bad branches, as the
problem is pretty quick to occur and didn't seem to be present in
2.6.20.

Jesse

 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
