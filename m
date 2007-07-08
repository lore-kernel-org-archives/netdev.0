From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: RFR: New e1000 driver (e1000new),
 was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sun, 08 Jul 2007 13:14:03 -0700
Message-ID: <4691458B.50403@linux.intel.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
	<468597F7.2050700@linux.intel.com> <46912AEA.3030604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46912AEA.3030604@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


> I reject the notion that a "flag day" switchover for a huge mass of 
> e1000 users is the correct path.  I do not think that best serves Linux 
> users.

so the options we have is do it one pci id a time; and the suggestion 
by others like Christoph has been to make the split at the PCI Express 
switchover. Do you agree with that approach?

> 
>> I appreciate the pain a temporary dual driver situation gives; it 
>> comes down to a few things that I can think of right now, if you see 
>> more please add to the list.
>>
>> 1) users who find a bug in the new one silently use the old one rather 
>> than reporting the bug; and only scream when the old one eventually 
>> goes away (see ALSA/OSS duplication)
>>
>> 2) users who enable both in KConfig may get a "random" one
>>
>> 3) distros really prefer only 1 driver per PCI ID for their 
>> infrastructure tools
>>
>> 4) there will be resistance against deleting the old one meaning it 
>> might not happen
> 
> You are missing the largest source of pain and headache:  Users will use 
> the default driver, which means no field testing at all until flag day, 
> with obvious results.

which is why the proposal that was below the text you quoted talks 
about working with the distro kernel maintainers and get the new 
driver default for their development releases etc etc.... that adds
a significant level of granularity. For example I'd not be surprised 
if Fedora and Ubuntu test releases have orders of magnitude more users 
than kernel.org "self compiloe" kernels.


> Furthermore, Linux kernel history demonstrates that "temporary dual 
> driver situations" are rarely temporary.  Thus, selling it as such in 
> the face of all contrary experience is pure hyperbole.

history also demonstrates it can be done (just look at Adrian Bunk and 
the OSS drivers) as long as someone is determined to do it. It's not 
easy, especially cases where the two drivers have different 
maintainers who disagree, or represent different 
interfaces/functionality; but it's very not impossible either.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
