From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: Re: [PATCH]sk98lin ethtool support
Date: Fri, 2 Jan 2004 00:00:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401012352180.11808-100000@localhost.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103424AA4@orsmsx402.jf.intel.com>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, <krishnakumar@naturesoft.net>,
        <mlindner@syskonnect.de>, <netdev@oss.sgi.com>, <felix@allot.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <demon@pro-linux.de>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0103424AA4@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Dec 2003, Mirko Lindner wrote:

> > Make sure you don't duplicate any ethtool functions.=A0 We don't need=
 a
> > NIC-specific diag tool either ;-)=A0 ethtool is the preferred method
> > moving forward, as it's already shipping in most Linux distros.
>=20
> Yes, we need it ;) No kidding! This is not a tool for SW checks like
> media, link or driver version checks, but a tool for HW checks like
> register, PROM, MAC, PHY and some other chip and card checks. The
> ethtool is a great tool, but the intention of this tool is not the same.

If the tool reports the results of running the h/w checks, then you can=20
use ETHTOOL_TEST.  The summary results of all the tests is reported as=20
PASS/FAIL.  Not sure if your tool needs to do more...

-scott
