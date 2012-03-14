From: Nin Lil'izi <nin-lil-izi@phoenixhaven.net>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver
 support
Date: Wed, 14 Mar 2012 15:20:37 +0000
Message-ID: <4F60B745.4010209@phoenixhaven.net>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no> <878vjeuebk.fsf@nemi.mork.no> <4F608D56.9070704@phoenixhaven.net> <87obrzjqfs.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0EED4550FFDD0D42D4219C73"
Cc: Nin Lil'izi <nin-lil-izi@cf-protected.phoenixhaven.net>,
	Greg KH <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:58455 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab2CNPUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 11:20:43 -0400
Received: by wibhj6 with SMTP id hj6so7335783wib.1
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 08:20:42 -0700 (PDT)
In-Reply-To: <87obrzjqfs.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0EED4550FFDD0D42D4219C73
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Radio hardware is a gimped Huaweii E398. Gimped as in supplied by the
telco with the 2g chip missing.
These are currently /the/ device supplied by the network '3' in the UK.
And as such are fast becoming very common devices over here.
I should also mention that I've made some modifications to the device
myself. Namely updating the firmware to someting more recent then
shipped as stock, and replacing the zerocd installer volume with the
most recent generic debranded huaweii image.

I'll take the userspace discussion to the other list.
lusb output below while in use using the option module on the stock arch
kernel (Linux Ninki 3.2.9-1-ARCH #1 SMP PREEMPT Thu Mar 1 09:31:13 CET
2012 x86_64 AMD C-60 APU with Radeon(tm) HD Graphics AuthenticAMD GNU/Lin=
ux)

[nin-lil-izi@Ninki ~]$ sudo lsusb -v -d 12d1:1506

Bus 001 Device 002: ID 12d1:1506 Huawei Technologies Co., Ltd. E398
LTE/UMTS/GSM Modem/Networkcard
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x12d1 Huawei Technologies Co., Ltd.
  idProduct          0x1506 E398 LTE/UMTS/GSM Modem/Networkcard
  bcdDevice            0.00
  iManufacturer           3 Huawei Technologies
  iProduct                2 HUAWEI Mobile
  iSerial                 0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength          161
    bNumInterfaces          6
    bConfigurationValue     1
    iConfiguration          1 Huawei Configuration
    bmAttributes         0xc0
      Self Powered
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      1
      bInterfaceProtocol      1
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x01  EP 1 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      1
      bInterfaceProtocol      7
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x84  EP 4 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      1
      bInterfaceProtocol      3
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x85  EP 5 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        3
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      1
      bInterfaceProtocol      2
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x86  EP 6 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x04  EP 4 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        4
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass         8 Mass Storage
      bInterfaceSubClass      6 SCSI
      bInterfaceProtocol     80 Bulk (Zip)
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x87  EP 7 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x05  EP 5 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        5
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass         8 Mass Storage
      bInterfaceSubClass      6 SCSI
      bInterfaceProtocol     80 Bulk (Zip)
      iInterface              0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x06  EP 6 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x88  EP 8 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0000
  (Bus Powered)



Regards,
/Nin lil'izi/

Skype: Nin-lil-izi
/Help me stay fed, order a certain and enevitable demise off me today!/
GPG Fingerprint: C510 909B 811E D6F5 0DFF 5D91 CF03 8FEA FD69 4622

On 14/03/12 12:51, Bj=C3=B8rn Mork wrote:
> "Nin Lil'izi" <nin-lil-izi@cf-protected.phoenixhaven.net> writes:
>
>> Please forgive me for spamming this list.
>> But is this module going to make it into the 3.3.0 final release?
>>
>> I've been testing it on my laptop while travelling on trains and thing=
s
>> using recent git pulls. And it releaves so much frustration vs the
>> option module.
>> As in spotty signal areas it drops in and out seamlessly without havin=
g
>> to manually reconnect everytime the train passes through a deadspot. A=
nd
>> generally the connection is noticiably more stable in this use case :D=

>>
>> Anyway I'd like to try it on my home connection which is run off an at=
om
>> device in a radio blackspot from hell. Which results in stuff having t=
o
>> be reconnected very often, even with huge external antenna attached. S=
o
>> this is like a dream come true in frustration saving but it takes
>> 12hours to build a kernel. And cross compilation is labour intensive
>> when you don't have the toolchain setup first. So am waiting for this =
to
>> hit a stable release before building it on that machine to save my san=
ity.
> Thanks for the nice feedback. =20
>
> This was submitted far too late for it to be considered 3.3 material.
> Not much to do about that.  Most of the developement happened after
> 3.3-rc1 anyway.  So I'm afraid you'll have to wait a couple months more=

> for the 3.4 release.
>
> I understand that wasn't the message you wanted, but it does give us al=
l
> a chance to test it thoroughly on different types of hardware. And mayb=
e
> even prepare some userspace tools :-)
>
> Which brings me to a couple of questions I have for you: What radio
> hardware do you use (lsusb -v), and which userspace tools?
>
> But we should maybe continue any userspace tool discussion here instead=
,
> where it's a bit more on topic:
> http://lists.freedesktop.org/mailman/listinfo/libqmi-devel
>
>
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in=

> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--------------enig0EED4550FFDD0D42D4219C73
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJPYLdFAAoJEM8Dj+r9aUYiUHAQAL5pExnqSgVVNiODyMUuHEpl
sfTTcp71GdcQ/go4NPwXDg1aJrPINoUDSn3JYZgc5X2N9u31FlZiQ6pDtOozII9l
zwoZ8RZAm61HvLY+QtYdrdRSYJ17I3VofaWsGKYwKIm7Va07Jc9+sRMc66kpntKY
BJAiMacPTDdEACLgpPJFpHoHzK/EDXfDk1FcKRqhoN/VilRtd6e4jXaMf/wWN7Ni
joN8e14damBNNZsiBCkvf07YctgV/t+7R6A1TJpD6UIunDailvK+YYifJINdb9El
uNXaUaX3rdi9OfH+NfdwKynafY5zMMs8+xBd/YVkxh98haUbYiTDaDQJrQveCuZh
ch718ASajnDLU1dVWQhslJMGWDJN92xbrE4O4En/pYVOJyaH2srnpCX0D6HZE+Pl
UIyJOpnXqsN+QpHo/YUWynfGOU0kjSrTJtfHnfncgM5BRxqaJD/TnKZk6qf504ry
VrzzycobuOKIVigXArq8vy3+RkLXfwEnnoFV9+nRymoEPV+cY5mfXYVtglQwMelS
tsco0RxlSnYnCXwjA+M+sm69/4ZGBuC8ZQQpI8REg5CtQdqwTFGNDua2u91qHi0C
6EPmA7k/NlWMjLKeGX81bcr1BnJJHlyoKUIKIkZw62rLteWLHUSnRlhnVOjmtxrb
PejetRcJySi8PU2jx9H9
=zn9N
-----END PGP SIGNATURE-----

--------------enig0EED4550FFDD0D42D4219C73--
