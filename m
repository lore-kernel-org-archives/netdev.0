From: "Kuchimanchi,
	Ramachandra \(Contractor - \)" <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] RE: [PATCH 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 1 May 2008 11:02:14 -0500
Message-ID: <C07C40DB2364324799506DE8FF12F8D8590EE0@EPEXCH1.qlogic.org>
References: <20080430171028.31725.86190.stgit@localhost.localdomain><20080430171955.31725.7771.stgit@localhost.localdomain>
	<20080501075606.4963afa3@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1660661233=="
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

--===============1660661233==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C8ABA4.B899E4BA"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8ABA4.B899E4BA
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Stephen,

Stephen Hemminger [mailto:shemminger@vyatta.com] wrote:

>> On Wed, 30 Apr 2008 22:49:55 +0530
>> Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:

<snip>

>> +static match_table_t vnic_opt_tokens =3D {
>> +	{VNIC_OPT_IOC_GUID, "ioc_guid=3D%s"},
>> +	{VNIC_OPT_DGID, "dgid=3D%s"},
>> +	{VNIC_OPT_PKEY, "pkey=3D%x"},
>> +	{VNIC_OPT_NAME, "name=3D%s"},
>> +	{VNIC_OPT_INSTANCE, "instance=3D%d"},
>> +	{VNIC_OPT_RXCSUM, "rx_csum=3D%s"},
>> +	{VNIC_OPT_TXCSUM, "tx_csum=3D%s"},
>> +	{VNIC_OPT_HEARTBEAT, "heartbeat=3D%d"},
>> +	{VNIC_OPT_IOC_STRING, "ioc_string=3D\"%s"},
>> +	{VNIC_OPT_IB_MULTICAST, "ib_multicast=3D%s"},
>> +	{VNIC_OPT_ERR, NULL}
>> +};
>>=20

> NO
> 1. Most of this shouldn't be done via sysfs (rx_csum, tx_csum, ...)
> 2. Sysfs is one value per file not name=3Dvalue

The VNIC driver needs multiple parameters (IOCGUID, DGID etc) from user =
space
to connect to the EVIC. For this the "name=3Dvalue" mechanism is used =
for
a write-only sysfs file as an input method to the driver.

The driver follows the one value per file sysfs rule when it returns any =
data
with each readable file returning only a single value.

Regards,
Ram

------_=_NextPart_001_01C8ABA4.B899E4BA
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
<TITLE>RE: [PATCH 08/13] QLogic VNIC: sysfs interface implementation for =
the driver</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>Stephen,<BR>
<BR>
Stephen Hemminger [<A =
HREF=3D"mailto:shemminger@vyatta.com">mailto:shemminger@vyatta.com</A>] =
wrote:<BR>
<BR>
&gt;&gt; On Wed, 30 Apr 2008 22:49:55 +0530<BR>
&gt;&gt; Ramachandra K &lt;ramachandra.kuchimanchi@qlogic.com&gt; =
wrote:<BR>
<BR>
&lt;snip&gt;<BR>
<BR>
&gt;&gt; +static match_table_t vnic_opt_tokens =3D {<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_IOC_GUID, =
&quot;ioc_guid=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_DGID, &quot;dgid=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_PKEY, &quot;pkey=3D%x&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_NAME, &quot;name=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_INSTANCE, =
&quot;instance=3D%d&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_RXCSUM, =
&quot;rx_csum=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_TXCSUM, =
&quot;tx_csum=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_HEARTBEAT, =
&quot;heartbeat=3D%d&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_IOC_STRING, =
&quot;ioc_string=3D\&quot;%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_IB_MULTICAST, =
&quot;ib_multicast=3D%s&quot;},<BR>
&gt;&gt; +&nbsp;&nbsp;&nbsp; {VNIC_OPT_ERR, NULL}<BR>
&gt;&gt; +};<BR>
&gt;&gt;<BR>
<BR>
&gt; NO<BR>
&gt; 1. Most of this shouldn't be done via sysfs (rx_csum, tx_csum, =
...)<BR>
&gt; 2. Sysfs is one value per file not name=3Dvalue<BR>
<BR>
The VNIC driver needs multiple parameters (IOCGUID, DGID etc) from user =
space<BR>
to connect to the EVIC. For this the &quot;name=3Dvalue&quot; mechanism =
is used for<BR>
a write-only sysfs file as an input method to the driver.<BR>
<BR>
The driver follows the one value per file sysfs rule when it returns any =
data<BR>
with each readable file returning only a single value.<BR>
<BR>
Regards,<BR>
Ram</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C8ABA4.B899E4BA--

--===============1660661233==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1660661233==--
