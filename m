From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 19:58:22 -0800
Message-ID: <CA+55aFxgNOdXonyKXRnKfyLM57_e4EpP+VYr6taUf2Bh5gCg9w@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
	<CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
	<CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
	<CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
	<CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
	<20150211014502.GB29656@ZenIV.linux.org.uk>
	<CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bdca5b6c49e21050ec80353
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45566 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbBKD6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 22:58:24 -0500
In-Reply-To: <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bdca5b6c49e21050ec80353
Content-Type: text/plain; charset=UTF-8

On Tue, Feb 10, 2015 at 6:01 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Are there no tests for that crypto interface?

Oh well.

With the attached, it at least does boot and work for me.

                        Linus

--047d7bdca5b6c49e21050ec80353
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i606tgdc0

IGNyeXB0by9hZl9hbGcuYyAgICAgICAgIHwgMiArLQogY3J5cHRvL2FsZ2lmX3NrY2lwaGVyLmMg
fCA1ICsrLS0tCiAyIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMo
LSkKCmRpZmYgLS1naXQgYS9jcnlwdG8vYWZfYWxnLmMgYi9jcnlwdG8vYWZfYWxnLmMKaW5kZXgg
ZWI3OGZlOGE2MGM4Li4zZTgwZDhiOGJlNDUgMTAwNjQ0Ci0tLSBhL2NyeXB0by9hZl9hbGcuYwor
KysgYi9jcnlwdG8vYWZfYWxnLmMKQEAgLTM0OCw3ICszNDgsNyBAQCBpbnQgYWZfYWxnX21ha2Vf
c2coc3RydWN0IGFmX2FsZ19zZ2wgKnNnbCwgc3RydWN0IGlvdl9pdGVyICppdGVyLCBpbnQgbGVu
KQogCWlmIChuIDwgMCkKIAkJcmV0dXJuIG47CiAKLQlucGFnZXMgPSBQQUdFX0FMSUdOKG9mZiAr
IG4pOworCW5wYWdlcyA9IChvZmYgKyBuICsgUEFHRV9TSVpFIC0gMSkgPj4gUEFHRV9TSElGVDsK
IAlpZiAoV0FSTl9PTihucGFnZXMgPT0gMCkpCiAJCXJldHVybiAtRUlOVkFMOwogCmRpZmYgLS1n
aXQgYS9jcnlwdG8vYWxnaWZfc2tjaXBoZXIuYyBiL2NyeXB0by9hbGdpZl9za2NpcGhlci5jCmlu
ZGV4IDM3MTEwZmQ2OGFkZi4uNmZjMTJjM2ZjNGI5IDEwMDY0NAotLS0gYS9jcnlwdG8vYWxnaWZf
c2tjaXBoZXIuYworKysgYi9jcnlwdG8vYWxnaWZfc2tjaXBoZXIuYwpAQCAtNDM5LDE0ICs0Mzks
MTMgQEAgc3RhdGljIGludCBza2NpcGhlcl9yZWN2bXNnKHN0cnVjdCBraW9jYiAqdW51c2VkLCBz
dHJ1Y3Qgc29ja2V0ICpzb2NrLAogCQl3aGlsZSAoIXNnLT5sZW5ndGgpCiAJCQlzZysrOwogCi0J
CXVzZWQgPSBjdHgtPnVzZWQ7Ci0JCWlmICghdXNlZCkgeworCQlpZiAoIWN0eC0+dXNlZCkgewog
CQkJZXJyID0gc2tjaXBoZXJfd2FpdF9mb3JfZGF0YShzaywgZmxhZ3MpOwogCQkJaWYgKGVycikK
IAkJCQlnb3RvIHVubG9jazsKIAkJfQogCi0JCXVzZWQgPSBtaW5fdCh1bnNpZ25lZCBsb25nLCB1
c2VkLCBpb3ZfaXRlcl9jb3VudCgmbXNnLT5tc2dfaXRlcikpOworCQl1c2VkID0gbWluX3QodW5z
aWduZWQgbG9uZywgY3R4LT51c2VkLCBpb3ZfaXRlcl9jb3VudCgmbXNnLT5tc2dfaXRlcikpOwog
CiAJCXVzZWQgPSBhZl9hbGdfbWFrZV9zZygmY3R4LT5yc2dsLCAmbXNnLT5tc2dfaXRlciwgdXNl
ZCk7CiAJCWVyciA9IHVzZWQ7Cg==
--047d7bdca5b6c49e21050ec80353--
