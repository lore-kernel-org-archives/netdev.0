From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: e1000 kills IPMI on 82541GI (Dell PE1425SC) +
 small 2.6.27 regression
Date: Tue, 11 Nov 2008 16:49:30 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811111624170.26561@bizon.gios.gov.pl>
References: <alpine.LNX.1.10.0810311012160.12764@bizon.gios.gov.pl>
	<F169D4F5E1F1974DBFAFABF47F60C10A0D2A5710@orsmsx507.amr.corp.intel.com>
	<alpine.LNX.1.10.0811010410110.12764@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="-1144830174-928292663-1226418571=:26561"
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LNX.1.10.0811010410110.12764@bizon.gios.gov.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-928292663-1226418571=:26561
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by bizon.gios.gov.pl id
	mABFnV2F007164

Hello,

On Sat, 1 Nov 2008, Krzysztof Oledzki wrote:

>
> On Fri, 31 Oct 2008, Brandeburg, Jesse wrote:
>
>> <modified the mail list a bit>
>>=20
>> Krzysztof Oledzki wrote:
>>> I have started implementing IPMI on my servers and there is some
>>> inconvenience with e1000+82541GI (Dell PE1425SC).

<CUT>

>> What if the IPMI traffic was *not* on a vlan but you had vlans enabled=
 in=20
>> your network?
>
> Good question, I'll check this.

OK, putting IPMI on a default, untagged vlan makes it working.

> > 1) 2.6.26 kernel with vlan enabled IPMI breaks doesn't work until=20
> > driver is loaded?
>
> I have a non-modular kernel with the driver build statically into it. I=
PMI=20
> obviously works before I booted a Linux kernel, not sure if making th d=
river=20
> modular changes anything (I hope not). With the statically linked drive=
r I=20
> have:
>
> <=3D2.6.26:
> - non-vlan host -> works
> - vlan host -> works with the dummy vlan
>
>> =3D2.6.27:
> - works only with the dummy vlan
>
> I'll retest with a modular configuration and let you know.

Just like I thought: vlan enabled IPMI *works* before the driver gets=20
loaded, runing "modprobe e1000; ifconfig eth0 up" kills IPMI on 2.6.27=20
and also kills it on older kernels when a first vlan is attached =3D when=
=20
"VLAN filter" becomes enabled.

Best regards,

 				Krzysztof Ol=EAdzki
---1144830174-928292663-1226418571=:26561
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
---1144830174-928292663-1226418571=:26561
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

---1144830174-928292663-1226418571=:26561--
