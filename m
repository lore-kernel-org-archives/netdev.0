From: Shawn Landden <shawnlandden@gmail.com>
Subject: Re: AF_ALG buggy with sendfile
Date: Sun, 24 Nov 2013 14:00:12 -0800
Message-ID: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
References: <CAJusiZVq3O1rok20HyYaoJDWxjtBdvMbDtjCif+sCyKPzpXMNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b41402e263c8804ebf35f1d
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-crypto@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJusiZVq3O1rok20HyYaoJDWxjtBdvMbDtjCif+sCyKPzpXMNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--047d7b41402e263c8804ebf35f1d
Content-Type: text/plain; charset=ISO-8859-1

heres a version of the test case that builds.....

Sorry about that.

On Sun, Nov 24, 2013 at 9:21 AM, Shawn Landden <shawnlandden@gmail.com> wrote:
> If I use sendfile() to send to a accept()ed AF_ALG socket set up for
> "hash", I get the wrong
> answer, if I read() and then write() I get the right answer. None of
> the system calls return an error.
>
> test case attached.
>
> --
>
> ---
> Shawn Landden
> +1 360 389 3001 (SMS preferred)



-- 

---
Shawn Landden
+1 360 389 3001 (SMS preferred)

--047d7b41402e263c8804ebf35f1d
Content-Type: text/x-csrc; charset=US-ASCII; name="af_alg.c"
Content-Disposition: attachment; filename="af_alg.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hoetxq0r1

CiNpbmNsdWRlIDxzeXMvc2VuZGZpbGUuaD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1
ZGUgPGxpbnV4L2lmX2FsZy5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN5cy9zdGF0
Lmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDx1bmlz
dGQuaD4KaW50IG1haW4odm9pZCkKewoJaW50IG9wZmQ7CglpbnQgdGZtZmQ7CglzdHJ1Y3Qgc29j
a2FkZHJfYWxnIHNhID0gewoJCS5zYWxnX2ZhbWlseSA9IEFGX0FMRywKCQkuc2FsZ190eXBlID0g
Imhhc2giLAoJCS5zYWxnX25hbWUgPSAic2hhMSIKCX07CgljaGFyICpidWYyOwoJY2hhciBidWZb
MjBdOwoJaW50IGk7CglzdHJ1Y3Qgc3RhdCBzdDsKCXNzaXplX3Qgc2l6ZTsKCgl0Zm1mZCA9IHNv
Y2tldChBRl9BTEcsIFNPQ0tfU0VRUEFDS0VULCAwKTsKCgliaW5kKHRmbWZkLCAoc3RydWN0IHNv
Y2thZGRyICopJnNhLCBzaXplb2Yoc2EpKTsKCglvcGZkID0gYWNjZXB0KHRmbWZkLCBOVUxMLCAw
KTsKCiAgICAgICAgaW50IHQgPSBvcGVuKCIvYmluL3RydWUiLCBPX1JET05MWSk7CiAgICAgICAg
ZnN0YXQodCwgJnN0KTsKCiAgICAgICAgc2l6ZSA9IHNlbmRmaWxlKG9wZmQsIHQsIE5VTEwsIHN0
LnN0X3NpemUpOwogICAgICAgIGlmIChzaXplICE9IHN0LnN0X3NpemUpCiAgICAgICAgICAgICAg
ICBleGl0KDEpOyAgICAgICAgICAgICAgICAKCXJlYWQob3BmZCwgJmJ1ZiwgMjApOwoKCWZvciAo
aSA9IDA7IGkgPCAyMDsgaSsrKSB7CgkJcHJpbnRmKCIlMDJ4IiwgKHVuc2lnbmVkIGNoYXIpYnVm
W2ldKTsKCX0KCXByaW50ZigiXG4iKTsKCiAgICAgICAgbHNlZWsodCwgMCwgU0VFS19TRVQpOwog
ICAgICAgIGJ1ZjIgPSBtYWxsb2Moc3Quc3Rfc2l6ZSArIDEpOwogICAgICAgIHJlYWQodCwgYnVm
Miwgc3Quc3Rfc2l6ZSk7CiAgICAgICAgd3JpdGUob3BmZCwgYnVmMiwgc3Quc3Rfc2l6ZSk7Cgly
ZWFkKG9wZmQsICZidWYsIDIwKTsKCglmb3IgKGkgPSAwOyBpIDwgMjA7IGkrKykgewoJCXByaW50
ZigiJTAyeCIsICh1bnNpZ25lZCBjaGFyKWJ1ZltpXSk7Cgl9CglwcmludGYoIlxuIik7CgoJY2xv
c2Uob3BmZCk7CgljbG9zZSh0Zm1mZCk7CgoJcmV0dXJuIDA7Cn0KCg==
--047d7b41402e263c8804ebf35f1d--
