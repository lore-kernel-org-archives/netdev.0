From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Intel 82559 NIC corrupted EEPROM
Date: Mon, 27 Nov 2006 12:34:06 -0800
Message-ID: <4807377b0611271234l131bf7d7l975ed7e46d8c7444@mail.gmail.com>
References: <454B7C3A.3000308@privacy.net> <454BF0F1.5050700@zytor.com>
	 <45506C9A.5010009@privacy.net> <4551B7B8.8080601@privacy.net>
	 <4807377b0611080926x21bd6326xc5e7683100d20948@mail.gmail.com>
	 <45533801.7000809@privacy.net>
	 <4807377b0611091619v6bfe17f4tbcbb64db0ab8ea9@mail.gmail.com>
	 <45546A93.6070905@privacy.net> <455AD123.4080804@privacy.net>
	 <456AF37C.8090304@privacy.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_34303_5392370.1164659646522"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	auke-jan.h.kok@intel.com, bunk@stusta.de, jgarzik@pobox.com,
	saw@saw.sw.com.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:57165 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1758574AbWK0UeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 15:34:11 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1259750uga
        for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 12:34:08 -0800 (PST)
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <456AF37C.8090304@privacy.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_34303_5392370.1164659646522
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/27/06, John <me@privacy.net> wrote:
> John wrote:
>
> >> 00000000-0009ffff : System RAM
> >> 000a0000-000bffff : Video RAM area
> >> 000f0000-000fffff : System ROM
> >> 00100000-0ffeffff : System RAM
> >>   00100000-00296a1a : Kernel code
> >>   00296a1b-0031bbe7 : Kernel data
> >> 0fff0000-0fff2fff : ACPI Non-volatile Storage
> >> 0fff3000-0fffffff : ACPI Tables
> >> 20000000-200fffff : 0000:00:08.0
> >> 20100000-201fffff : 0000:00:09.0
> >> 20200000-202fffff : 0000:00:0a.0
> >> e0000000-e3ffffff : 0000:00:00.0
> >> e5000000-e50fffff : 0000:00:08.0
> >> e5100000-e51fffff : 0000:00:09.0
> >> e5200000-e52fffff : 0000:00:0a.0
> >> e5300000-e5300fff : 0000:00:08.0
> >> e5301000-e5301fff : 0000:00:0a.0
> >> e5302000-e5302fff : 0000:00:09.0
> >> ffff0000-ffffffff : reserved
> >>
> >> I've also attached:
> >>
> >> o config-2.6.18.1-adlink used to compile this kernel
> >> o dmesg output after the machine boots
> >
> > I suppose the information I've sent is not enough to locate the
> > root of the problem. Is there more I can provide?
>
> Here is some context for those who have been added to the CC list:
> http://groups.google.com/group/linux.kernel/browse_frm/thread/bdc8fd08fb601c26
>
> As far as I understand, some consider the eepro100 driver to be
> obsolete, and it has been considered for removal.
>
> What is the current status?
>
> Unfortunately, e100 does not work out-of-the-box on this system.
>
> Is there something I can do to improve the situation?

lets go ahead and print the output from e100_load_eeprom
debug patch attached.

------=_Part_34303_5392370.1164659646522
Content-Type: application/octet-stream; name=e100_debug.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ev1c96eb
Content-Disposition: attachment; filename="e100_debug.patch"

W2UxMDBdIGRlYnVnIGVlcHJvbSBwcm9ibGVtcwoKU2lnbmVkLW9mZi1ieTogSmVzc2UgQnJhbmRl
YnVyZyA8amVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20+CgotLS0KCiBkcml2ZXJzL25ldC9lMTAw
LmMgfCAgICAyICsrCiAxIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9lMTAwLmMgYi9kcml2ZXJzL25ldC9lMTAw
LmMKaW5kZXggMTlhYjM0NC4uMzc2ZmYyZCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZTEwMC5j
CisrKyBiL2RyaXZlcnMvbmV0L2UxMDAuYwpAQCAtNzQ2LDEwICs3NDYsMTIgQEAgc3RhdGljIGlu
dCBlMTAwX2VlcHJvbV9sb2FkKHN0cnVjdCBuaWMgKgogCiAJLyogVHJ5IHJlYWRpbmcgd2l0aCBh
biA4LWJpdCBhZGRyIGxlbiB0byBkaXNjb3ZlciBhY3R1YWwgYWRkciBsZW4gKi8KIAllMTAwX2Vl
cHJvbV9yZWFkKG5pYywgJmFkZHJfbGVuLCAwKTsKKwlEUFJJTlRLKFBST0JFLCBJTkZPLCAiYWRk
cl9sZW4gMHglMDRYXG4iLCBhZGRyX2xlbik7CiAJbmljLT5lZXByb21fd2MgPSAxIDw8IGFkZHJf
bGVuOwogCiAJZm9yKGFkZHIgPSAwOyBhZGRyIDwgbmljLT5lZXByb21fd2M7IGFkZHIrKykgewog
CQluaWMtPmVlcHJvbVthZGRyXSA9IGUxMDBfZWVwcm9tX3JlYWQobmljLCAmYWRkcl9sZW4sIGFk
ZHIpOworCQlEUFJJTlRLKFBST0JFLCBJTkZPLCAiZWVwcm9tWyVkXSA9IDB4JTA0WFxuIiwgYWRk
ciwgbmljLT5lZXByb21bYWRkcl0pOwogCQlpZihhZGRyIDwgbmljLT5lZXByb21fd2MgLSAxKQog
CQkJY2hlY2tzdW0gKz0gY3B1X3RvX2xlMTYobmljLT5lZXByb21bYWRkcl0pOwogCX0K
------=_Part_34303_5392370.1164659646522--
