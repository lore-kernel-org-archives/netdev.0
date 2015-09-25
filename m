From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Forcing the output interface using ip6_route_output doesn't work
Date: Fri, 25 Sep 2015 15:13:03 -0600
Message-ID: <5605B8DF.2070603@cumulusnetworks.com>
References: <560552A7.40305@linux-dude.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060106030409010808090401"
To: Wolfgang Nothdurft <netdev@linux-dude.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34309 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933346AbbIYVNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:13:06 -0400
Received: by padhy16 with SMTP id hy16so115932056pad.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 14:13:05 -0700 (PDT)
In-Reply-To: <560552A7.40305@linux-dude.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060106030409010808090401
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 9/25/15 7:56 AM, Wolfgang Nothdurft wrote:
> It seems that the ip6_route_output(net, sk, fl6) kernel function ignores
> the fl6.flowi6_oif parameter for the routing decision.

It is considered, but a mismatch is not considered fatal.

I think the attached should fix your problem.



--------------060106030409010808090401
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="ip6-rt-get-with-oif.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ip6-rt-get-with-oif.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3JvdXRlLmMgYi9uZXQvaXB2Ni9yb3V0ZS5jCmluZGV4
IDExOGY4ZmExYTgwOS4uY2M1MjQ1OGY3MjI2IDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9yb3V0
ZS5jCisrKyBiL25ldC9pcHY2L3JvdXRlLmMKQEAgLTExNjksNyArMTE2OSw4IEBAIHN0cnVj
dCBkc3RfZW50cnkgKmlwNl9yb3V0ZV9vdXRwdXQoc3RydWN0IG5ldCAqbmV0LCBjb25zdCBz
dHJ1Y3Qgc29jayAqc2ssCiAKIAlmbDYtPmZsb3dpNl9paWYgPSBMT09QQkFDS19JRklOREVY
OwogCi0JaWYgKChzayAmJiBzay0+c2tfYm91bmRfZGV2X2lmKSB8fCBydDZfbmVlZF9zdHJp
Y3QoJmZsNi0+ZGFkZHIpKQorCWlmICgoc2sgJiYgc2stPnNrX2JvdW5kX2Rldl9pZikgfHwg
cnQ2X25lZWRfc3RyaWN0KCZmbDYtPmRhZGRyKSB8fAorCSAgICAgZmw2LT5mbG93aTZfb2lm
KQogCQlmbGFncyB8PSBSVDZfTE9PS1VQX0ZfSUZBQ0U7CiAKIAlpZiAoIWlwdjZfYWRkcl9h
bnkoJmZsNi0+c2FkZHIpKQo=
--------------060106030409010808090401--
