From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH][XFRM_TUNNEL]: Reload header pointer after pskb_may_pull/pskb_expand_head
Date: Sat, 24 Feb 2007 23:49:50 -0200
Message-ID: <39e6f6c70702241749l4c7128afyeed881245c2e3ac2@mail.gmail.com>
References: <39e6f6c70702241747l19dd1b21l9a28f7d6f64a4a6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_84207_6441852.1172368190349"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:10611 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933608AbXBYBtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 20:49:51 -0500
Received: by wx-out-0506.google.com with SMTP id h31so932537wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 17:49:51 -0800 (PST)
In-Reply-To: <39e6f6c70702241747l19dd1b21l9a28f7d6f64a4a6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_84207_6441852.1172368190349
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Oops, now with the patch.

- Arnaldo

On 2/24/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> Hi David,
>
>            Please consider applying, this was found on your latest
> net-2.6 tree while playing around with that ip_hdr() + turn
> skb->nh/h/mac pointers  as offsets on 64 bits idea :-)
>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> Regards,
>
> - Arnaldo
>

------=_Part_84207_6441852.1172368190349
Content-Type: text/x-patch; name=a.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eyktppws
Content-Disposition: attachment; filename="a.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3hmcm00X21vZGVfdHVubmVsLmMgYi9uZXQvaXB2NC94ZnJt
NF9tb2RlX3R1bm5lbC5jCmluZGV4IGUxY2FiMzMuLjQ3NDM3NmYgMTAwNjQ0Ci0tLSBhL25ldC9p
cHY0L3hmcm00X21vZGVfdHVubmVsLmMKKysrIGIvbmV0L2lwdjQveGZybTRfbW9kZV90dW5uZWwu
YwpAQCAtMTExLDYgKzExMSw3IEBAIHN0YXRpYyBpbnQgeGZybTRfdHVubmVsX2lucHV0KHN0cnVj
dCB4ZnJtX3N0YXRlICp4LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCSAgICAoZXJyID0gcHNrYl9l
eHBhbmRfaGVhZChza2IsIDAsIDAsIEdGUF9BVE9NSUMpKSkKIAkJZ290byBvdXQ7CiAKKwlpcGgg
PSBza2ItPm5oLmlwaDsKIAlpZiAoaXBoLT5wcm90b2NvbCA9PSBJUFBST1RPX0lQSVApIHsKIAkJ
aWYgKHgtPnByb3BzLmZsYWdzICYgWEZSTV9TVEFURV9ERUNBUF9EU0NQKQogCQkJaXB2NF9jb3B5
X2RzY3AoaXBoLCBza2ItPmguaXBpcGgpOwo=
------=_Part_84207_6441852.1172368190349--
