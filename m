From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 13:08:27 -0400
Message-ID: <CAB9dFdsVxzi_Tx2yvStXLr2qvqd4ht4H1BRM8A5E1x-cBMv4mg@mail.gmail.com>
References: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
	<CAB9dFdswyri4-pDZ+uoAk00isP8Lba7-uqYPXnT=PnLataJeHg@mail.gmail.com>
	<CAEfhGixbKf7+j_4KUvNSQL96N+-9SsDSaH0CmfL=iwWFAYDeMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114a97f6025a590529b2eb25
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Craig Gallek <kraig@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEfhGixbKf7+j_4KUvNSQL96N+-9SsDSaH0CmfL=iwWFAYDeMg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a114a97f6025a590529b2eb25
Content-Type: text/plain; charset=UTF-8

On Tue, Jan 19, 2016 at 12:31 PM, Craig Gallek <kraig@google.com> wrote:
>
> I need to think about how to handle setsockopt-after-bind condition a
> bit more, but the NULL pointer dereference is obviously wrong.  Do you
> have a way to easily reproduce this?  I've only managed to get it to
> happen once so far...

The attached code reliably triggers the crash for me.

--001a114a97f6025a590529b2eb25
Content-Type: text/x-csrc; charset=US-ASCII; name="reuseport_crash.c"
Content-Disposition: attachment; filename="reuseport_crash.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ijlnjkoy0

I2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5jbHVkZSA8
dW5pc3RkLmg+CgojaW5jbHVkZSA8YXJwYS9pbmV0Lmg+CgppbnQKbWFpbihpbnQgYXJnYywgY2hh
ciAqKmFyZ3YpCnsKICAgIHN0cnVjdCBzb2NrYWRkcl9pbiBhZGRyLCBhZGRyMjsKICAgIGludCBs
ZW4sIG9wdHZhbCA9IDE7CiAgICBpbnQgczEsIHMyOwoKICAgIGFkZHIuc2luX2FkZHIuc19hZGRy
ID0gaHRvbmwoSU5BRERSX0FOWSk7CiAgICBhZGRyLnNpbl9mYW1pbHkgPSBBRl9JTkVUOwogICAg
YWRkci5zaW5fcG9ydCA9IDA7CgogICAgczEgPSBzb2NrZXQoQUZfSU5FVCwgU09DS19ER1JBTSwg
SVBQUk9UT19VRFApOwogICAgczIgPSBzb2NrZXQoQUZfSU5FVCwgU09DS19ER1JBTSwgSVBQUk9U
T19VRFApOwoKICAgIGJpbmQoczEsIChzdHJ1Y3Qgc29ja2FkZHIgKikmYWRkciwgc2l6ZW9mKGFk
ZHIpKTsKICAgIHNldHNvY2tvcHQoczEsIFNPTF9TT0NLRVQsIFNPX1JFVVNFUE9SVCwgJm9wdHZh
bCwgc2l6ZW9mKG9wdHZhbCkpOwogICAgc2V0c29ja29wdChzMiwgU09MX1NPQ0tFVCwgU09fUkVV
U0VQT1JULCAmb3B0dmFsLCBzaXplb2Yob3B0dmFsKSk7CgogICAgbGVuID0gc2l6ZW9mKGFkZHIp
OwogICAgZ2V0c29ja25hbWUoczEsIChzdHJ1Y3Qgc29ja2FkZHIgKikmYWRkciwgKHNvY2tsZW5f
dCAqKSZsZW4pOwogICAgYWRkcjIuc2luX2FkZHIuc19hZGRyID0gaHRvbmwoSU5BRERSX0FOWSk7
CiAgICBhZGRyMi5zaW5fZmFtaWx5ID0gQUZfSU5FVDsKICAgIGFkZHIyLnNpbl9wb3J0ID0gYWRk
ci5zaW5fcG9ydDsKICAgIGJpbmQoczIsIChzdHJ1Y3Qgc29ja2FkZHIgKikmYWRkcjIsIHNpemVv
ZihhZGRyKSk7CiAgICBjbG9zZShzMik7CiAgICBjbG9zZShzMSk7CiAgICByZXR1cm4gMDsKfQo=
--001a114a97f6025a590529b2eb25--
