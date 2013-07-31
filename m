From: Ming Lei <ming.lei@canonical.com>
Subject: Re: issues with commit usbnet: mcs7830: apply usbnet_link_change
Date: Wed, 31 Jul 2013 23:49:48 +0800
Message-ID: <CACVXFVMwbCjcfeSeD907FDRoqkdN6YDYZ5mxt36ZZceenK8EGQ@mail.gmail.com>
References: <51F8DF64.4030108@schmalmack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b3435f6de80ef04e2d0ac7c
Cc: Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: Till Schmalmack <till@schmalmack.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34592 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765Ab3GaPtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:49:50 -0400
In-Reply-To: <51F8DF64.4030108@schmalmack.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b3435f6de80ef04e2d0ac7c
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jul 31, 2013 at 5:56 PM, Till Schmalmack <till@schmalmack.net> wrote:
> Hello Ming,
>
> I am experiencing issues with the usbnet commits you did for the 3.10
> kernel, in particular with
>
> 4be74c13 usbnet: mcs7830: apply usbnet_link_change
>
> I filed this bug
>
> https://bugzilla.kernel.org/show_bug.cgi?id=60662

Thanks for the report.

Looks you didn't provide any debug info, could you apply the attachment
patch and post the 'dmesg' info when you reproduce the bug.


Thanks,
--
Ming Lei

--047d7b3435f6de80ef04e2d0ac7c
Content-Type: application/octet-stream; name="usbnet-link-dgb.patch"
Content-Disposition: attachment; filename="usbnet-link-dgb.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hjspipbx0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3VzYi91c2JuZXQuYyBiL2RyaXZlcnMvbmV0L3VzYi91
c2JuZXQuYwppbmRleCAwNmVlODJmLi4xNDIwNDE4IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC91
c2IvdXNibmV0LmMKKysrIGIvZHJpdmVycy9uZXQvdXNiL3VzYm5ldC5jCkBAIC0xMDA0LDYgKzEw
MDQsOCBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IGV0aHRvb2xfb3BzIHVzYm5ldF9ldGh0b29sX29w
cyA9IHsKIAogc3RhdGljIHZvaWQgX19oYW5kbGVfbGlua19jaGFuZ2Uoc3RydWN0IHVzYm5ldCAq
ZGV2KQogeworCWludCBsaW5rOworCiAJaWYgKCF0ZXN0X2JpdChFVkVOVF9ERVZfT1BFTiwgJmRl
di0+ZmxhZ3MpKQogCQlyZXR1cm47CiAKQEAgLTEwMTUsMTIgKzEwMTcsMTUgQEAgc3RhdGljIHZv
aWQgX19oYW5kbGVfbGlua19jaGFuZ2Uoc3RydWN0IHVzYm5ldCAqZGV2KQogCQkgKiB0eF90aW1l
b3V0IHdpbGwgdW5saW5rIFVSQnMgZm9yIHNlbmRpbmcgcGFja2V0cyBhbmQKIAkJICogdHggcXVl
dWUgaXMgc3RvcHBlZCBieSBuZXRjb3JlIGFmdGVyIGxpbmsgYmVjb21lcyBvZmYKIAkJICovCisJ
CWxpbmsgPSAwOwogCX0gZWxzZSB7CiAJCS8qIHN1Ym1pdHRpbmcgVVJCcyBmb3IgcmVhZGluZyBw
YWNrZXRzICovCiAJCXRhc2tsZXRfc2NoZWR1bGUoJmRldi0+YmgpOworCQlsaW5rID0gMTsKIAl9
CiAKIAljbGVhcl9iaXQoRVZFTlRfTElOS19DSEFOR0UsICZkZXYtPmZsYWdzKTsKKwlkZXZfaW5m
bygmZGV2LT51ZGV2LT5kZXYsICIlcyBsaW5rPSVkXG4iLCBfX2Z1bmNfXywgbGluayk7CiB9CiAK
IC8qIHdvcmsgdGhhdCBjYW5ub3QgYmUgZG9uZSBpbiBpbnRlcnJ1cHQgY29udGV4dCB1c2VzIGtl
dmVudGQuCkBAIC0xNzQ4LDYgKzE3NTMsOCBAQCBFWFBPUlRfU1lNQk9MKHVzYm5ldF9tYW5hZ2Vf
cG93ZXIpOwogCiB2b2lkIHVzYm5ldF9saW5rX2NoYW5nZShzdHJ1Y3QgdXNibmV0ICpkZXYsIGJv
b2wgbGluaywgYm9vbCBuZWVkX3Jlc2V0KQogeworCWRldl9pbmZvKCZkZXYtPnVkZXYtPmRldiwg
IiVzIGxpbms9JWQgcmVzZXQ9JWRcbiIsIF9fZnVuY19fLCBsaW5rLAorCQkJbmVlZF9yZXNldCk7
CiAJLyogdXBkYXRlIGxpbmsgYWZ0ZXIgbGluayBpcyByZXNldGVkICovCiAJaWYgKGxpbmsgJiYg
IW5lZWRfcmVzZXQpCiAJCW5ldGlmX2NhcnJpZXJfb24oZGV2LT5uZXQpOwo=
--047d7b3435f6de80ef04e2d0ac7c--
