From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH][UDP]: Fix "whitespace" cleanup
Date: Mon, 5 Mar 2007 00:40:19 -0300
Message-ID: <39e6f6c70703041940u38fd7c9ds3407f3e61cdcb050@mail.gmail.com>
References: <39e6f6c70703041911u446bb4a0q324d5087237a57a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_125601_11350937.1173066019665"
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:5892 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbXCEDkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 22:40:21 -0500
Received: by wr-out-0506.google.com with SMTP id 37so1216776wra
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2007 19:40:20 -0800 (PST)
In-Reply-To: <39e6f6c70703041911u446bb4a0q324d5087237a57a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_125601_11350937.1173066019665
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 3/5/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> Hi David, Stephen
>
>        Whitespace cleanups have to pass the compile test too ;-) This
> is just in net-2.6.22 tho :-)
>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>

There is one more problem:

-       __u16 destp       = ntohs(inet->dport);
-       __u16 srcp        = ntohs(inet->sport);
+       __u16 dest  = ntohs(inet->dport);
+       __u16 srcp  = ntohs(inet->sport);

It changes 'destp' to dest, and there is already a dest variable,
updated patch attached,

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

------=_Part_125601_11350937.1173066019665
Content-Type: text/x-patch; name=udp.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eywd7giv
Content-Disposition: attachment; filename="udp.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggNTMwOWRk
NS4uNDViNThhYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lwdjQvdWRw
LmMKQEAgLTE5Niw3ICsxOTYsNyBAQCBnb3RpdDoKIAkJCWlmIChzazItPnNrX2hhc2ggPT0gc251
bSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJiYKIAkJCSAgICBzazIgIT0gc2sgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJiYKIAkJCSAgICAoIXNrMi0+c2tfcmV1
c2UgICAgICAgIHx8ICFzay0+c2tfcmV1c2UpICAgICAgICAgJiYKLQkJCSAgICAgfHwgc2syLT5z
a19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikgJiYKKwkJCSAgICAoc2syLT5z
a19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikgICAgJiYKIAkJCSAgICAoKnNh
ZGRyX2NvbXApKHNrLCBzazIpKQogCQkJCWdvdG8gZmFpbDsKIAl9CkBAIC0xNjYwLDcgKzE2NjAs
NyBAQCBzdGF0aWMgdm9pZCB1ZHA0X2Zvcm1hdF9zb2NrKHN0cnVjdCBzb2NrICpzcCwgY2hhciAq
dG1wYnVmLCBpbnQgYnVja2V0KQogCXN0cnVjdCBpbmV0X3NvY2sgKmluZXQgPSBpbmV0X3NrKHNw
KTsKIAlfX2JlMzIgZGVzdCA9IGluZXQtPmRhZGRyOwogCV9fYmUzMiBzcmMgID0gaW5ldC0+cmN2
X3NhZGRyOwotCV9fdTE2IGRlc3QgID0gbnRvaHMoaW5ldC0+ZHBvcnQpOworCV9fdTE2IGRlc3Rw
ID0gbnRvaHMoaW5ldC0+ZHBvcnQpOwogCV9fdTE2IHNyY3AgID0gbnRvaHMoaW5ldC0+c3BvcnQp
OwogCiAJc3ByaW50Zih0bXBidWYsICIlNGQ6ICUwOFg6JTA0WCAlMDhYOiUwNFgiCg==
------=_Part_125601_11350937.1173066019665--
