From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at	skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 16:43:34 +0300
Message-ID: <4C727B06.2060002@fs.uni-ruse.bg>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg> <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg> <20100823124736.GA16966@ff.dom.local> <1282568443.2486.34.camel@edumazet-laptop> <20100823131056.GA19160@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_fs-6910-1282571015-0001-2"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:45512 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752819Ab0HWNnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 09:43:37 -0400
In-Reply-To: <20100823131056.GA19160@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_fs-6910-1282571015-0001-2
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

На 23.8.2010 г. 16:10, Jarek Poplawski написа:
> On Mon, Aug 23, 2010 at 03:00:43PM +0200, Eric Dumazet wrote:
> ...
>> I was about to suggest a similar patch ;)
>>
>> Also prints skb->csum_offset and skb->len if possible
>
> Feel free to send it: I'm a bit in hurry now...
>
> Jarek P.

Currently compiling the kernel with the attached patch.

And, by the way, if there are any patches to follow, would you
please, send them as attachments? I think my mail client is
line-wrapping the patches...

The results will be sent soon, too.

Plamen

--=_fs-6910-1282571015-0001-2
Content-Type: text/plain; name="tg3-gro-debug.patch"; charset=iso-8859-1
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tg3-gro-debug.patch"

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKaW5kZXggMzcy
MWZiYi4uMjRhNTNkMCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZGV2LmMKKysrIGIvbmV0L2Nv
cmUvZGV2LmMKQEAgLTE5MzUsNiArMTkzNSwyNiBAQCBzdGF0aWMgaW5saW5lIGludCBza2Jf
bmVlZHNfbGluZWFyaXplKHN0cnVjdCBza19idWZmICpza2IsCiAJCQkJCSAgICAgIGlsbGVn
YWxfaGlnaGRtYShkZXYsIHNrYikpKSk7CiB9CiAKK3N0YXRpYyBpbnQgc2tiX2NzdW1fc3Rh
cnRfYnVnKHN0cnVjdCBza19idWZmICpza2IpCit7CisKKwlpZiAoc2tiLT5pcF9zdW1tZWQg
PT0gQ0hFQ0tTVU1fUEFSVElBTCkgeworCQlsb25nIGNzc3RhcnQ7CisJCQorCQljc3N0YXJ0
ID0gc2tiLT5jc3VtX3N0YXJ0IC0gc2tiX2hlYWRyb29tKHNrYik7CisJCWlmIChXQVJOX09O
KGNzc3RhcnQgPiBza2JfaGVhZGxlbihza2IpKSkgeworCQkgICAgcHJfd2FybmluZygiY3N1
bV9zdGFydCAldSwgb2Zmc2V0ICV1LCBoZWFkcm9vbSAlZCwgaGVhZGxlbiAlZCwgbGVuICVk
XG4iLAorCQkJc2tiLT5jc3VtX3N0YXJ0LAorCQkJc2tiLT5jc3VtX29mZnNldCwKKwkJCXNr
Yl9oZWFkcm9vbShza2IpLAorCQkJc2tiX2hlYWRsZW4oc2tiKSwKKwkJCXNrYi0+bGVuKTsK
KwkJICAgIHJldHVybiAxOworCQl9CisJfQorCXJldHVybiAwOworfQorCiBpbnQgZGV2X2hh
cmRfc3RhcnRfeG1pdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgbmV0X2RldmljZSAq
ZGV2LAogCQkJc3RydWN0IG5ldGRldl9xdWV1ZSAqdHhxKQogewpAQCAtMTk1NSwxMSArMTk3
NSwxMyBAQCBpbnQgZGV2X2hhcmRfc3RhcnRfeG1pdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBz
dHJ1Y3QgbmV0X2RldmljZSAqZGV2LAogCQlza2Jfb3JwaGFuX3RyeShza2IpOwogCiAJCWlm
IChuZXRpZl9uZWVkc19nc28oZGV2LCBza2IpKSB7CisJCQlza2JfY3N1bV9zdGFydF9idWco
c2tiKTsKIAkJCWlmICh1bmxpa2VseShkZXZfZ3NvX3NlZ21lbnQoc2tiKSkpCiAJCQkJZ290
byBvdXRfa2ZyZWVfc2tiOwogCQkJaWYgKHNrYi0+bmV4dCkKIAkJCQlnb3RvIGdzbzsKIAkJ
fSBlbHNlIHsKKwkJCXNrYl9jc3VtX3N0YXJ0X2J1Zyhza2IpOwogCQkJaWYgKHNrYl9uZWVk
c19saW5lYXJpemUoc2tiLCBkZXYpICYmCiAJCQkgICAgX19za2JfbGluZWFyaXplKHNrYikp
CiAJCQkJZ290byBvdXRfa2ZyZWVfc2tiOwpAQCAtMTk5Nyw3ICsyMDE5LDEyIEBAIGdzbzoK
IAkJaWYgKGRldi0+cHJpdl9mbGFncyAmIElGRl9YTUlUX0RTVF9SRUxFQVNFKQogCQkJc2ti
X2RzdF9kcm9wKG5za2IpOwogCi0JCXJjID0gb3BzLT5uZG9fc3RhcnRfeG1pdChuc2tiLCBk
ZXYpOworCQlpZiAoc2tiX2NzdW1fc3RhcnRfYnVnKHNrYikpIHsKKwkJICAgIGtmcmVlX3Nr
Yihza2IpOworCQkgICAgcmMgPSBORVRERVZfVFhfT0s7CisJCX0gZWxzZQorCQkgICAgcmMg
PSBvcHMtPm5kb19zdGFydF94bWl0KG5za2IsIGRldik7CisJCSAgICAKIAkJaWYgKHVubGlr
ZWx5KHJjICE9IE5FVERFVl9UWF9PSykpIHsKIAkJCWlmIChyYyAmIH5ORVRERVZfVFhfTUFT
SykKIAkJCQlnb3RvIG91dF9rZnJlZV9nc29fc2tiOwo=
--=_fs-6910-1282571015-0001-2--
