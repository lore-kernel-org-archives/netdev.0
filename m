From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: qmi_wwan on Huawei E398
Date: Fri, 11 Jan 2013 19:27:53 +0000
Message-ID: <34bc2a91-d03c-4143-8194-5dbe3b55530a@email.android.com>
References: <CABvLYuAX=r_Y0AdDtNp5g0kRYeP6suhLe_b68a7sQYJ-i7wrvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Cedric Jehasse <cedric.jehasse@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56368 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab3AKT2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 14:28:13 -0500
In-Reply-To: <CABvLYuAX=r_Y0AdDtNp5g0kRYeP6suhLe_b68a7sQYJ-i7wrvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cedric Jehasse <cedric.jehasse@gmail.com> wrote:

>Hi,
>
>I'm trying to use qmi on an Huawei E398 dongle with ofono on a 3.7.1
>kernel. (this works with a 3.5.0 kernel)
>ofono looks for the class/subclass/protocol of the parent
>usb_interface device for the qmi_wwan and cdc_wdm devices. This must
>match with ff/01/08 and ff/01/09 Cls/Sub/Prot.
>
>Below is a trace of the udev events and usb-device output for a 3.5.0
>and 3.7.1 kernel. The difference is in the parent devices for wwan0
>and cdc-wdm0.
>The parent device for wwan0 is on a 3.7.1 kernel is If3. Is this
>normal?
>
>* 3.5.0:
>KERNEL[201.262240] add
>/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usb/cdc-wdm0 (usb)
>KERNEL[201.347292] add
>/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.4/net/wwan0 (net)
>
>T:  Bus=3D02 Lev=3D01 Prnt=3D01 Port=3D05 Cnt=3D01 Dev#=3D  4 Spd=3D48=
0 MxCh=3D 0
>D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D =
 1
>P:  Vendor=3D12d1 ProdID=3D150a Rev=3D00.00
>S:  Manufacturer=3DHuawei Technologies
>S:  Product=3DHUAWEI Mobile
>S:  SerialNumber=3D1234567890ABCDEF
>C:  #Ifs=3D 7 Cfg#=3D 1 Atr=3Dc0 MxPwr=3D500mA
>I:  If#=3D 0 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D01 Prot=3D01 Dri=
ver=3Doption
>I:  If#=3D 1 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D02 Dri=
ver=3Doption
>I:  If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D03 Dri=
ver=3Doption
>I:  If#=3D 3 Alt=3D 0 #EPs=3D 1 Cls=3Dff(vend.) Sub=3D01 Prot=3D09 Dri=
ver=3Dcdc_wdm
>I:  If#=3D 4 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D08 Dri=
ver=3Dqmi_wwan
>I:  If#=3D 5 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50
>Driver=3Dusb-storage
>I:  If#=3D 6 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50
>Driver=3Dusb-storage
>
>* 3.7.1:
>KERNEL[61750.414019] add
>/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usbmisc/cdc-wdm0
>(usbmisc)
>KERNEL[61750.414019] add
>/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usbmisc/cdc-wdm0
>(usbmisc)
>
>T:  Bus=3D02 Lev=3D01 Prnt=3D01 Port=3D05 Cnt=3D01 Dev#=3D  6 Spd=3D48=
0 MxCh=3D 0
>D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D =
 1
>P:  Vendor=3D12d1 ProdID=3D150a Rev=3D00.00
>S:  Manufacturer=3DHuawei Technologies
>S:  Product=3DHUAWEI Mobile
>S:  SerialNumber=3D1234567890ABCDEF
>C:  #Ifs=3D 7 Cfg#=3D 1 Atr=3Dc0 MxPwr=3D500mA
>I:  If#=3D 0 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D01 Prot=3D01 Dri=
ver=3Doption
>I:  If#=3D 1 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D02 Dri=
ver=3Doption
>I:  If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D03 Dri=
ver=3Doption
>I:  If#=3D 3 Alt=3D 0 #EPs=3D 1 Cls=3Dff(vend.) Sub=3D01 Prot=3D09 Dri=
ver=3Dqmi_wwan
>I:  If#=3D 4 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3D01 Prot=3D08 Dri=
ver=3Dqmi_wwan
>I:  If#=3D 5 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50
>Driver=3Dusb-storage
>I:  If#=3D 6 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50
>Driver=3Dusb-storage
>
>Thanks,
>Cedric

This looks right to me. There is a single function using two USB interf=
aces. We started out letting the cdc-wdm driver handle the control inte=
rface and the qmi_wwan driver the data interface. This is what you see =
in 3.5. But splitting a function like this was very awkward and made de=
vices like the E398 behave differently from most other QMI devices, whi=
ch only use a single USB interface.=20

So we changed this to let the qmi_wwan driver handle both interfaces. T=
his is what you see in 3.7. The control interface is now the parent of =
both the cdc_wdm character device and the wwan network device and the d=
ata interface is just a data interface.

I realize that this is balancing on the edge of acceptable userspace vi=
sible changes, but all this did was making devices like the E398 look s=
imilar to single interface devices. Which already had to be supported b=
y the userspace applications.

Now I understand that ofono does a lot stricter matching than I have an=
ticipated, looking at the vendor specific subclass and protocol fields =
of the wwan parent interface. I don't think we can fix that without upd=
ating ofono. Sorry. If it is going to do that then it needs to accept b=
oth ff/01/08 and ff/01/09.


Bj=C3=B8rn
