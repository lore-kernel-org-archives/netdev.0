From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 16:27:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC3EF234C.805B7E11-ON85256D9E.007550C8-86256D9E.0075B0AD@us.ibm.com>
References: <3F60DE5B.1010700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, scott.feldman@intel.com,
   davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <3F60DE5B.1010700@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



      Do not make these a UDP issue. It is much easier today to overrun t=
he
Tx queue as  N TCP connections can be running in parallel on different
CPU's.

You can see these on the data I sent out.

regards,

-------------------------------------------------------------------------=
---------

***  ALWAYS THINK POSITIVE ***

Rick Gonzalez
IBM Linux Performance Group
Building: 905    Office: 7G019
Phone: (512) 838-0623

Jeff Garzik <jgarzik@pobox.com> on 09/11/2003 03:43:07 PM

To:    Ricardo C Gonzalez/Austin/IBM@ibmus
cc:    scott.feldman@intel.com, greearb@candelatech.com
Subject:    Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default



Ricardo C Gonzalez wrote:
> The default Tx queue can easly be overrun by today=E2=80=99s SMP
> systems
> taking into consideration that these are 4way systems at Ghz speeds.


As I said, this is expected.

And please CC the netdev@oss.sgi.com mailing list, where technical
discussions like this are held.

 Jeff
