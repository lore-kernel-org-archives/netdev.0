From: "Kuchimanchi,
	Ramachandra \(Contractor - \)" <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] RE: [PATCH 11/13] QLogic VNIC: Driver utility file -
	implements various utility macros
Date: Thu, 1 May 2008 11:18:53 -0500
Message-ID: <C07C40DB2364324799506DE8FF12F8D8590EE1@EPEXCH1.qlogic.org>
References: <20080430171028.31725.86190.stgit@localhost.localdomain><20080430172126.31725.48554.stgit@localhost.localdomain>
	<20080501075816.1010ec3a@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1063738993=="
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	"Poornima Kamath \(Contractor - \)" <poornima.kamath@qlogic.com>,
	general@lists.openfabrics.org,
	"Amar Mudrankit \(Contractor - \)" <amar.mudrankit@qlogic.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1063738993==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C8ABA7.0C5333A4"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8ABA7.0C5333A4
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Stephen,

Stephen Hemminger [mailto:shemminger@vyatta.com] wrote:

> Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:

>> +#define is_power_of2(value)	(((value) & ((value - 1))) =3D=3D 0)
>> +#define ALIGN_DOWN(x, a)	((x)&(~((a)-1)))

> In kernel.h already

Will fix this. Thanks.

>> +extern u32 vnic_debug;

> Use msg level macros instead?

I am sorry, I did not understand this comment.

> +
> +#define SYS_INFO(fmt, arg...)					\
> +	 PRINT_CONDITIONAL(KERN_INFO,				\
> +			   "SYS",				\
> +			   (vnic_debug & DEBUG_SYS_INFO),	\
> +			   fmt, ##arg)
> +
> +#endif	/* VNIC_UTIL_H_INCLUDED */


> Many of these are already in standard macros pr_info, pr_err etc.

These macros are for providing a debug log level functionality through
the vnic_debug module parameter.

Regards,
Ram

------_=_NextPart_001_01C8ABA7.0C5333A4
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7651.59">
<TITLE>RE: [PATCH 11/13] QLogic VNIC: Driver utility file - implements =
various utility macros</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>Stephen,<BR>
<BR>
Stephen Hemminger [<A =
HREF=3D"mailto:shemminger@vyatta.com">mailto:shemminger@vyatta.com</A>] =
wrote:<BR>
<BR>
&gt; Ramachandra K &lt;ramachandra.kuchimanchi@qlogic.com&gt; wrote:<BR>
<BR>
&gt;&gt; +#define is_power_of2(value) (((value) &amp; ((value - 1))) =
=3D=3D 0)<BR>
&gt;&gt; +#define ALIGN_DOWN(x, a)&nbsp;&nbsp;&nbsp; =
((x)&amp;(~((a)-1)))<BR>
<BR>
&gt; In kernel.h already<BR>
<BR>
Will fix this. Thanks.<BR>
<BR>
&gt;&gt; +extern u32 vnic_debug;<BR>
<BR>
&gt; Use msg level macros instead?<BR>
<BR>
I am sorry, I did not understand this comment.<BR>
<BR>
&gt; +<BR>
&gt; +#define SYS_INFO(fmt, =
arg...)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \<BR>
&gt; +&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
PRINT_CONDITIONAL(KERN_INFO,&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \<BR>
&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; =
&quot;SYS&quot;,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \<BR>
&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; (vnic_debug =
&amp; DEBUG_SYS_INFO),&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \<BR>
&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp; fmt, ##arg)<BR>
&gt; +<BR>
&gt; +#endif&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* VNIC_UTIL_H_INCLUDED =
*/<BR>
<BR>
<BR>
&gt; Many of these are already in standard macros pr_info, pr_err =
etc.<BR>
<BR>
These macros are for providing a debug log level functionality =
through<BR>
the vnic_debug module parameter.<BR>
<BR>
Regards,<BR>
Ram</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C8ABA7.0C5333A4--

--===============1063738993==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1063738993==--
