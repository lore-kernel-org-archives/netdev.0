From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] [Bugme-new] [Bug 12570] New:
	Bonding does not work over e1000e.
Date: Tue, 17 Mar 2009 11:04:36 -0400
Message-ID: <bdfc5d6e0903170804m2c3d8d0bra6bdd50dc67971be@mail.gmail.com>
References: <8DD2590731AB5D4C9DBF71A877482A900DCA8695@orsmsx509.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F60321240@rrsmsx501.amr.corp.intel.com>
	<F169D4F5E1F1974DBFAFABF47F60C10A1C2C9480@orsmsx507.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F60321411@rrsmsx501.amr.corp.intel.com>
	<13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com>
	<498C0E8C.9050309@parallels.com>
	<13830B75AD5A2F42848F92269B11996F3C5C645A@orsmsx509.amr.corp.intel.com>
	<49BFB2F0.8090704@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devel@lists.sourceforge.net" <devel@lists.sourceforge.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Konstantin Khorenko <khorenko@parallels.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <49BFB2F0.8090704@parallels.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Mar 17, 2009 at 10:25 AM, Konstantin Khorenko
<khorenko@parallels.com> wrote:
>
> Conclusions: well, the latest kernel with your patches does work, thank y=
ou very much, David!
> Now i have to solve my original problem - to make RHEL5-based (2.6.18-x) =
kernel working.
> At the moment RHEL5 kernel is affected by 2 issues:
> 1) that one which seems to be fixed by updating the testkernel from 2.6.2=
9-r1 up to rc4 + 3 your patches.
> 2) when we break a link, mii status is still reported as "up" in /proc/ne=
t/bonding/bond1.
> =A0 (at the same time bonding changes the active slave to the working one=
 correctly).
>
> i understand there were a lot of changes since 2.6.18, but i still want t=
o try not to replace the e1000e driver completely from the latest mainstrea=
m kernel, but to backport the set of patches to fix this exact issue.
> Could you please help me pointing the patches that are essential to fix t=
his issue (and probably issue 2)) from your point of view?
>

I'm sure if you opened a new bug at bugzilla.redhat.com to address
this issue someone would be willing to make sure this was fixed.

---------------------------------------------------------------------------=
---
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
