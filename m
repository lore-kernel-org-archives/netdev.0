From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 6/12] include/linux/usb/cdc.h:23: error:
 redefinition of 'struct usb_cdc_parsed_header'
Date: Wed, 16 Sep 2015 21:06:58 +0800
Message-ID: <20150916130658.GB24184@wfg-t540p.sh.intel.com>
References: <201509160310.FiynyPOo%fengguang.wu@intel.com>
 <20150915.132742.739418011603329556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oneukum@suse.com, kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13023 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbbIPNG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 09:06:59 -0400
Content-Disposition: inline
In-Reply-To: <20150915.132742.739418011603329556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 01:27:42PM -0700, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Wed, 16 Sep 2015 03:57:11 +0800
>=20
> > All error/warnings (new ones prefixed by >>):
> >=20
> >    In file included from drivers/usb/gadget/function/u_ether.h:20,
> >                     from drivers/usb/gadget/legacy/cdc2.c:16:
> >    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' decl=
ared inside parameter list
> >    include/linux/usb/cdc.h:47: warning: its scope is only this defi=
nition or declaration, which is probably not what you want
> >    In file included from drivers/usb/gadget/function/u_serial.h:16,
> >                     from drivers/usb/gadget/legacy/cdc2.c:17:
> >>> include/linux/usb/cdc.h:23: error: redefinition of 'struct usb_cd=
c_parsed_header'
> >    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' decl=
ared inside parameter list
> >>> include/linux/usb/cdc.h:47: error: conflicting types for 'cdc_par=
se_cdc_header'
> >    include/linux/usb/cdc.h:47: error: previous declaration of 'cdc_=
parse_cdc_header' was here
>=20
> This may be a side effect of the initial warning, does this reproduce=
 with
> that fixed?  Please show me what the warning looks like in that case.

Dave, net-next/master commit ad1e7b97b3 ("cdc: Fix build warning.")
still has errors.

The problem is, the header file <linux/usb/cdc.h> is included twice.

recent_errors
=E2=94=9C=E2=94=80=E2=94=80 arm-arm5
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:conflicting-types-for-cdc_parse_cdc_header
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=9C=E2=94=80=E2=94=80 arm-arm67
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:conflicting-types-for-cdc_parse_cdc_header
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=9C=E2=94=80=E2=94=80 arm-mmp
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:conflicting-types-for-cdc_parse_cdc_header
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=9C=E2=94=80=E2=94=80 arm-omap2plus_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:conflicting-types-for-cdc_parse_cdc_header
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=9C=E2=94=80=E2=94=80 avr32-atngw100_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=9C=E2=94=80=E2=94=80 avr32-atstk1006_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc=
=2Eh:error:redefinition-of-struct-usb_cdc_parsed_header
=E2=94=94=E2=94=80=E2=94=80 i386-allmodconfig
    =E2=94=9C=E2=94=80=E2=94=80 include-linux-usb-cdc.h:error:conflicti=
ng-types-for-cdc_parse_cdc_header
    =E2=94=94=E2=94=80=E2=94=80 include-linux-usb-cdc.h:error:redefinit=
ion-of-struct-usb_cdc_parsed_header

The error messages are now:

In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/function/f_ncm.c:26:
include/linux/usb/cdc.h:23:8: error: redefinition of 'struct usb_cdc_pa=
rsed_header'
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/f_ncm.c:24:0:
include/linux/usb/cdc.h:23:8: note: originally defined here
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/function/f_ncm.c:26:
include/linux/usb/cdc.h:44:5: error: conflicting types for 'cdc_parse_c=
dc_header'
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^
In file included from drivers/usb/gadget/function/f_ncm.c:24:0:
include/linux/usb/cdc.h:44:5: note: previous declaration of 'cdc_parse_=
cdc_header' was here
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^

Thanks,
=46engguang
