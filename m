From: Mirko Lindner <mlindner@syskonnect.de>
Subject: Re: [RFT] simplify skge /proc interface.
Date: Fri, 5 Sep 2003 09:27:11 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1220606764.18887.129.camel@mlindner-lin>
References: <20030904160658.5ae22c0d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, Ralph Roesler <rroesler@syskonnect.de>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030904160658.5ae22c0d.shemminger@osdl.org>
Date: 05 Sep 2008 11:26:04 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thank you for the submission,

the latest driver version 6.17 (still by Linus) has a lot of
proc-changes. I=C2=B4ll insert the remaining changes into our tree and ma=
ke a
new release next week.

Cheers,

Mirko




On Fri, 2003-09-05 at 01:06, Stephen Hemminger wrote:
> This patch is against 2.6.0-test4 and simplifys the /proc interface for
> the skge driver. =20
>=20
> * Use seq_file single_open interface to avoid possible buffer over
>   run and formatting issues.
> * Put pointer to device in the proc dir private data to avoid having
>   to search through devices to find the info.
> * Use %lld rather than special formatting code
> * use proc_mkdir
> * Don't die if proc fs is not configured or creating entries fails.
>=20
> New code is written in kernel style.
>=20
> Builds and loads but don't have real hardware. Could someone
> please test this with a real board?
>=20
> Somewhere in this 8K line driver is a 1000 line driver waiting to get o=
ut...
>=20
