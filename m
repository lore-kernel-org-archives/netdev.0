From: Matt Domsch <Matt_Domsch@dell.com>
Subject: RE: [Bonding-devel] Re: [bonding] Add basic support for dynamic
 configuration of bond interfaces
Date: Mon, 12 Jan 2004 20:34:07 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401122032480.6491-100000@humbolt.us.dell.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDCC@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, "Noam, Amir" <amir.noam@intel.com>,
        Jay Vosburgh <fubar@us.ibm.com>, <bonding-devel@lists.sourceforge.net>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDCC@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Could sysfs be used for the bonding UI?=A0 Seems like a natural fit.
> Something like:
> # echo "some params" >/sys/class/net/add_bond
> # echo "byebye" >/sys/class/net/bond0/del_bond

FWIW, this is exactly what we're doing with the efivars module to create=20
and destroy EFI Variables now, and appears to be a sane approach.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
