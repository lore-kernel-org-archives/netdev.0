From: Wei Liu <liuw@liuw.name>
Subject: Re: [PATCH 0/4] Implement persistent grant in
	xen-netfront/netback
Date: Thu, 15 Nov 2012 17:35:13 +0800
Message-ID: <CAOsiSVU+9fkGQhVhnrx=xxUD8hej55XXJGpKGWAxe1USPEhiEQ@mail.gmail.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	<20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0487768002020222232=="
Cc: netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <50A4AA06.8080900@oracle.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============0487768002020222232==
Content-Type: multipart/alternative; boundary=f46d04447fb108b73304ce856095

--f46d04447fb108b73304ce856095
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 15, 2012 at 4:38 PM, ANNIE LI <annie.li@oracle.com> wrote:

>
>
> On 2012-11-15 15:40, Pasi K=C3=A4rkk=C3=A4inen wrote:
>
>> Hello,
>>
>> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
>>
>>> This patch implements persistent grants for xen-netfront/netback. This
>>> mechanism maintains page pools in netback/netfront, these page pools is
>>> used to
>>> save grant pages which are mapped. This way improve performance which i=
s
>>> wasted
>>> when doing grant operations.
>>>
>>> Current netback/netfront does map/unmap grant operations frequently whe=
n
>>> transmitting/receiving packets, and grant operations costs much cpu
>>> clock. In
>>> this patch, netfront/netback maps grant pages when needed and then save=
s
>>> them
>>> into a page pool for future use. All these pages will be unmapped when
>>> removing/releasing the net device.
>>>
>>>  Do you have performance numbers available already? with/without
>> persistent grants?
>>
> I have some simple netperf/netserver test result with/without persistent
> grants,
>
> Following is result of with persistent grant patch,
>
> Guests, Sum,      Avg,     Min,     Max
>  1,  15106.4,  15106.4, 15106.36, 15106.36
>  2,  13052.7,  6526.34,  6261.81,  6790.86
>  3,  12675.1,  6337.53,  6220.24,  6454.83
>  4,  13194,  6596.98,  6274.70,  6919.25
>
>
> Following are result of without persistent patch
>
> Guests, Sum,     Avg,    Min,        Max
>  1,  10864.1,  10864.1, 10864.10, 10864.10
>  2,  10898.5,  5449.24,  4862.08,  6036.40
>  3,  10734.5,  5367.26,  5261.43,  5473.08
>  4,  10924,    5461.99,  5314.84,  5609.14
>
>
>
Interesting results. Have you tested how good it is on a 10G nic, i.e.
guest sending packets
through physical network to another host.


Wei.

--f46d04447fb108b73304ce856095
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><div class=3D"gmail_extra"><div class=3D"gmail_quote">On Thu, Nov 15, 2=
012 at 4:38 PM, ANNIE LI <span dir=3D"ltr">&lt;<a href=3D"mailto:annie.li@o=
racle.com" target=3D"_blank">annie.li@oracle.com</a>&gt;</span> wrote:<br><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex">

<div class=3D"im"><br>
<br>
On 2012-11-15 15:40, Pasi K=C3=A4rkk=C3=A4inen wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hello,<br>
<br>
On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
This patch implements persistent grants for xen-netfront/netback. This<br>
mechanism maintains page pools in netback/netfront, these page pools is use=
d to<br>
save grant pages which are mapped. This way improve performance which is wa=
sted<br>
when doing grant operations.<br>
<br>
Current netback/netfront does map/unmap grant operations frequently when<br=
>
transmitting/receiving packets, and grant operations costs much cpu clock. =
In<br>
this patch, netfront/netback maps grant pages when needed and then saves th=
em<br>
into a page pool for future use. All these pages will be unmapped when<br>
removing/releasing the net device.<br>
<br>
</blockquote>
Do you have performance numbers available already? with/without persistent =
grants?<br>
</blockquote></div>
I have some simple netperf/netserver test result with/without persistent gr=
ants,<br>
<br>
Following is result of with persistent grant patch,<br>
<br>
Guests, Sum, =C2=A0 =C2=A0 =C2=A0Avg, =C2=A0 =C2=A0 Min, =C2=A0 =C2=A0 Max<=
br>
=C2=A01, =C2=A015106.4, =C2=A015106.4, 15106.36, 15106.36<br>
=C2=A02, =C2=A013052.7, =C2=A06526.34, =C2=A06261.81, =C2=A06790.86<br>
=C2=A03, =C2=A012675.1, =C2=A06337.53, =C2=A06220.24, =C2=A06454.83<br>
=C2=A04, =C2=A013194, =C2=A06596.98, =C2=A06274.70, =C2=A06919.25<br>
<br>
<br>
Following are result of without persistent patch<br>
<br>
Guests, Sum, =C2=A0 =C2=A0 Avg, =C2=A0 =C2=A0Min, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Max<br>
=C2=A01, =C2=A010864.1, =C2=A010864.1, 10864.10, 10864.10<br>
=C2=A02, =C2=A010898.5, =C2=A05449.24, =C2=A04862.08, =C2=A06036.40<br>
=C2=A03, =C2=A010734.5, =C2=A05367.26, =C2=A05261.43, =C2=A05473.08<br>
=C2=A04, =C2=A010924, =C2=A0 =C2=A05461.99, =C2=A05314.84, =C2=A05609.14<di=
v class=3D"im"><br>
<br></div></blockquote><div><br></div><div>Interesting results. Have you te=
sted how good it is on a 10G nic, i.e. guest sending packets</div><div>thro=
ugh physical network to another host.</div><div><br></div><div><br></div>

<div>Wei.</div></div></div>

--f46d04447fb108b73304ce856095--


--===============0487768002020222232==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============0487768002020222232==--
