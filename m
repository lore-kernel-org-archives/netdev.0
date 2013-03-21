From: Wei Liu <liuw@liuw.name>
Subject: Re: [PATCH 4/4] xen-netback: coalesce slots before
	copying
Date: Thu, 21 Mar 2013 19:08:44 +0000
Message-ID: <CAOsiSVWSRmo1+Ubo7GyAKcvUr8XUenkMvnAqt607gPoJm-sXFQ@mail.gmail.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	<1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
	<6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
	<6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5644581122641862226=="
Cc: Wei Liu <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: James Harper <james.harper@bendigoit.com.au>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============5644581122641862226==
Content-Type: multipart/alternative; boundary=089e0122903219c80004d8741338

--089e0122903219c80004d8741338
Content-Type: text/plain; charset=UTF-8

On Mon, Mar 18, 2013 at 1:27 PM, James Harper <james.harper@bendigoit.com.au
> wrote:
>
>  >
>
> Actually it turns out GPLPV just stops counting at 20. If I keep counting
> I can sometimes see over 1000 buffers per GSO packet under Windows using
> "iperf -


Do you think it is necessary to increase MAX_SKB_SLOTS_DEFAULT to 21?


Wei.

--089e0122903219c80004d8741338
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Mon, Mar 18, 2013 at 1:27 PM, James Harper <span dir=3D"ltr">&lt=
;<a href=3D"mailto:james.harper@bendigoit.com.au" target=3D"_blank">james.h=
arper@bendigoit.com.au</a>&gt;</span> wrote:<blockquote class=3D"gmail_quot=
e" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-colo=
r:rgb(204,204,204);border-left-style:solid;padding-left:1ex">

<div class=3D"im">
&gt;<br>
<br>
</div>Actually it turns out GPLPV just stops counting at 20. If I keep coun=
ting I can sometimes see over 1000 buffers per GSO packet under Windows usi=
ng &quot;iperf -</blockquote><div><br></div><div style>Do you think it is n=
ecessary to increase=C2=A0<span style=3D"font-family:arial,sans-serif;font-=
size:13px">MAX_SKB_SLOTS_DEFAULT</span>=C2=A0to 21?</div>

<div>=C2=A0</div><div><br></div><div style>Wei.</div></div></div></div>

--089e0122903219c80004d8741338--


--===============5644581122641862226==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============5644581122641862226==--
