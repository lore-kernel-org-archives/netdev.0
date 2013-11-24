From: Shawn Landden <shawnlandden@gmail.com>
Subject: AF_ALG buggy with sendfile
Date: Sun, 24 Nov 2013 09:21:57 -0800
Message-ID: <CAJusiZVq3O1rok20HyYaoJDWxjtBdvMbDtjCif+sCyKPzpXMNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bdc131e08105a04ebef7c26
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--047d7bdc131e08105a04ebef7c26
Content-Type: text/plain; charset=ISO-8859-1

If I use sendfile() to send to a accept()ed AF_ALG socket set up for
"hash", I get the wrong
answer, if I read() and then write() I get the right answer. None of
the system calls return an error.

test case attached.

-- 

---
Shawn Landden
+1 360 389 3001 (SMS preferred)

--047d7bdc131e08105a04ebef7c26
Content-Type: text/x-csrc; charset=US-ASCII; name="af_alg.c"
Content-Disposition: attachment; filename="af_alg.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hoek04oa0

CiNpbmNsdWRlIDxzeXMvc2VuZGZpbGUuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1
ZGUgPGxpbnV4L2lmX2FsZy5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN5cy9zdGF0
Lmg+CiNpbmNsdWRlIDxmY250bC5oPgoKaW50IG1haW4odm9pZCkKewoJaW50IG9wZmQ7CglpbnQg
dGZtZmQ7CglzdHJ1Y3Qgc29ja2FkZHJfYWxnIHNhID0gewoJCS5zYWxnX2ZhbWlseSA9IEFGX0FM
RywKCQkuc2FsZ190eXBlID0gImhhc2giLAoJCS5zYWxnX25hbWUgPSAic2hhMSIKCX07CgljaGFy
IGJ1ZjJbMTAwMDAwMDBdOwoJY2hhciBidWZbMjBdOwoJaW50IGk7CglzdHJ1Y3Qgc3RhdCBzdDsK
Cgl0Zm1mZCA9IHNvY2tldChBRl9BTEcsIFNPQ0tfU0VRUEFDS0VULCAwKTsKCgliaW5kKHRmbWZk
LCAoc3RydWN0IHNvY2thZGRyICopJnNhLCBzaXplb2Yoc2EpKTsKCglvcGZkID0gYWNjZXB0KHRm
bWZkLCBOVUxMLCAwKTsKCiAgICAgICAgaW50IHRydWUgPSBvcGVuKCIvYmluL3RydWUiLCBPX1JE
T05MWSk7CiAgICAgICAgZnN0YXQodHJ1ZSwgJnN0KTsKCiAgICAgICAgc2VuZGZpbGUob3BmZCwg
dHJ1ZSwgTlVMTCwgc3Quc3Rfc2l6ZSk7CglyZWFkKG9wZmQsICZidWYsIDIwKTsKCglmb3IgKGkg
PSAwOyBpIDwgMjA7IGkrKykgewoJCXByaW50ZigiJTAyeCIsICh1bnNpZ25lZCBjaGFyKWJ1Zltp
XSk7Cgl9CglwcmludGYoIlxuIik7CgogICAgICAgIGxzZWVrKHRydWUsIDAsIFNFRUtfU0VUKTsK
ICAgICAgICByZWFkKHRydWUsICZidWYyLCBzdC5zdF9zaXplKTsKICAgICAgICB3cml0ZShvcGZk
LCAmYnVmMiwgc3Quc3Rfc2l6ZSk7CglyZWFkKG9wZmQsICZidWYsIDIwKTsKCglmb3IgKGkgPSAw
OyBpIDwgMjA7IGkrKykgewoJCXByaW50ZigiJTAyeCIsICh1bnNpZ25lZCBjaGFyKWJ1ZltpXSk7
Cgl9CglwcmludGYoIlxuIik7CgoJY2xvc2Uob3BmZCk7CgljbG9zZSh0Zm1mZCk7CgoJcmV0dXJu
IDA7Cn0KCg==
--047d7bdc131e08105a04ebef7c26--
