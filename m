From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [patch] pegasus.c
Date: Tue, 19 Feb 2008 10:11:13 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0802191002500.3219@bender.nucleusys.com>
References: <alpine.DEB.1.00.0801091222560.3171@bender.nucleusys.com> <47B06BF4.7010009@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811350-1862151011-1203408310=:3219"
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.cabletel.bg ([89.253.152.15]:38284 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750832AbYBSIL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 03:11:28 -0500
In-Reply-To: <47B06BF4.7010009@garzik.org>
Content-ID: <alpine.DEB.1.00.0802191005570.3219@bender.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811350-1862151011-1203408310=:3219
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Content-ID: <alpine.DEB.1.00.0802191005571.3219@bender.nucleusys.com>

This is another attempt on sending the pegasus patch with Alpine.  I know 
it's even worse, but i've attached gzip-ed version just in case.

Here goes a brief description of what's changed:

---
This patch is fixing a driver bug triggered when malformed string is 
passed to the 'devid' module parameter.  The expected format is:

 	"device_name:vendor_id:device_id:flags"

but it turned out people often type:

 	"somename::0"

instead of:

 	"somename:::0"

which typically ends up dereferencing null pointer.


Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---


cheers,
Petko


On Mon, 11 Feb 2008, Jeff Garzik wrote:

> Petko Manolov wrote:
>>     Hi Jeff,
>> 
>> Attached you'll find a patch that is fixing a driver bug triggered when 
>> malformed string is passed to the 'devid' module parameter.  The expected 
>> format is:
>>
>>     "device_name:vendor_id:device_id:flags"
>> 
>> but it turned out people often type:
>>
>>     "somename::0"
>> 
>> instead of:
>>
>>     "somename:::0"
>
> ACK but two process problems preventing application:
>
> * patch is base64-encoded
>
> * no signed-off-by included
>
>
>
---1463811350-1862151011-1203408310=:3219
Content-Type: APPLICATION/OCTET-STREAM; NAME=pegasus.c.patch.gz
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.1.00.0802191005100.3219@bender.nucleusys.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=pegasus.c.patch.gz

H4sICL2MukcAA3BlZ2FzdXMuYy5wYXRjaAClU11v0zAUfU5/xaXSWNI4bVJK
1iWqNFgnUWkgJNheAEUhcTuLxI5sp+sL/53rJO1AKaITeWj9cXzuOffD8zzI
JdtSqSac6kmtvk8quklVrcbZWEi2saa+P/f8wPMvIZhGQRi9no79/Qeuj/cD
13X/TnOEYd5juLoCL5iFAQmm4DaL6QzwUOlUswy2guVQpVLRhOV29pBKGLHc
GcAALLYG29biB+WwQDxiKvslywkMo6HjwIsFfLi7vUWsZfG0pAhqwPHAtWih
KP5ZG6EFUCljBE1G0MC4eIRKMK4V4iEFXhcFaCpLxlNNcxOJ8c1o8jwFW8pz
IdGEQbKyKmiCD7Soi5aANFACQegcF+g+L15OtyyjJ8bzrHWRblQfarj/qctt
dGGkQ3wE/A8hWBVmiq+FPTxTEXD6CK0dOFME2kzCagn+7syf7cj+8reTJnpk
truvfEiQEbqv7dbEVJpA+3sozZ6pWTYUKBG6Fr0ISWg6dD4nF6c0qGVJqmvJ
46ZX16jYZgs/BhyRBMMg+gv7NjYKYmCu67TG+7eYwwbUu+zysHjS38d0mVk8
GYs7O/NXrZ3LkATBSX66ucZjZajLVGcPyb7Md5/eJsub+9X1TbJaJu/ffL5+
1+3j/lOW3x/V3oN9lCKvM/2nftNw+9TiGnsmwpNDx5RpgckucVDPzaP8HEok
KagxhXnEQcaOMHX9aQrTucZphwQJmIaDCNzYJhvO4BdrcxYvLQUAAA==

---1463811350-1862151011-1203408310=:3219
Content-Type: TEXT/x-diff; name=pegasus.c.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.1.00.0802191011130.3219@bender.nucleusys.com>
Content-Description: 
Content-Disposition: attachment; filename=pegasus.c.patch

LS0tIGRyaXZlcnMvbmV0L3VzYi9wZWdhc3VzLmMub3JpZwkyMDA4LTAxLTA5
IDEyOjE2OjUyLjAwMDAwMDAwMCArMDIwMA0KKysrIGRyaXZlcnMvbmV0L3Vz
Yi9wZWdhc3VzLmMJMjAwOC0wMS0wOSAxMjoxNjo1OC4wMDAwMDAwMDAgKzAy
MDANCkBAIC0xNDYxLDEyICsxNDYxLDI0IEBAIHN0YXRpYyB2b2lkIHBhcnNl
X2lkKGNoYXIgKmlkKQ0KIA0KIAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwg
IjoiKSkgIT0gTlVMTCkNCiAJCW5hbWUgPSB0b2tlbjsNCisJZWxzZQ0KKwkJ
Z290byBlcnI7DQogCS8qIG5hbWUgbm93IHBvaW50cyB0byBhIG51bGwgdGVy
bWluYXRlZCBzdHJpbmcqLw0KIAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwg
IjoiKSkgIT0gTlVMTCkNCiAJCXZlbmRvcl9pZCA9IHNpbXBsZV9zdHJ0b3Vs
KHRva2VuLCBOVUxMLCAxNik7DQorCWVsc2UNCisJCWdvdG8gZXJyOw0KKw0K
IAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwgIjoiKSkgIT0gTlVMTCkNCiAJ
CWRldmljZV9pZCA9IHNpbXBsZV9zdHJ0b3VsKHRva2VuLCBOVUxMLCAxNik7
DQotCWZsYWdzID0gc2ltcGxlX3N0cnRvdWwoaWQsIE5VTEwsIDE2KTsNCisJ
ZWxzZQ0KKwkJZ290byBlcnI7DQorDQorCWlmIChpZCAhPSBOVUxMKQ0KKwkJ
ZmxhZ3MgPSBzaW1wbGVfc3RydG91bChpZCwgTlVMTCwgMTYpOw0KKwllbHNl
DQorCQlnb3RvIGVycjsNCisNCiAJcHJfaW5mbygiJXM6IG5ldyBkZXZpY2Ug
JXMsIHZlbmRvciBJRCAweCUwNHgsIGRldmljZSBJRCAweCUwNHgsIGZsYWdz
OiAweCV4XG4iLA0KIAkgICAgICAgIGRyaXZlcl9uYW1lLCBuYW1lLCB2ZW5k
b3JfaWQsIGRldmljZV9pZCwgZmxhZ3MpOw0KIA0KQEAgLTE0NzYsNiArMTQ4
OCw3IEBAIHN0YXRpYyB2b2lkIHBhcnNlX2lkKGNoYXIgKmlkKQ0KIAkJcmV0
dXJuOw0KIA0KIAlmb3IgKGk9MDsgdXNiX2Rldl9pZFtpXS5uYW1lOyBpKysp
Ow0KKw0KIAl1c2JfZGV2X2lkW2ldLm5hbWUgPSBuYW1lOw0KIAl1c2JfZGV2
X2lkW2ldLnZlbmRvciA9IHZlbmRvcl9pZDsNCiAJdXNiX2Rldl9pZFtpXS5k
ZXZpY2UgPSBkZXZpY2VfaWQ7DQpAQCAtMTQ4Myw2ICsxNDk2LDExIEBAIHN0
YXRpYyB2b2lkIHBhcnNlX2lkKGNoYXIgKmlkKQ0KIAlwZWdhc3VzX2lkc1tp
XS5tYXRjaF9mbGFncyA9IFVTQl9ERVZJQ0VfSURfTUFUQ0hfREVWSUNFOw0K
IAlwZWdhc3VzX2lkc1tpXS5pZFZlbmRvciA9IHZlbmRvcl9pZDsNCiAJcGVn
YXN1c19pZHNbaV0uaWRQcm9kdWN0ID0gZGV2aWNlX2lkOw0KKw0KKwlyZXR1
cm47DQorDQorZXJyOg0KKwlwcl9pbmZvKCJtYWxmb3JtZWQgJ2RldmlkJyBt
b2R1bGUgcGFyYW1ldGVyXG4iKTsNCiB9DQogDQogc3RhdGljIGludCBfX2lu
aXQgcGVnYXN1c19pbml0KHZvaWQpDQo=

---1463811350-1862151011-1203408310=:3219--
