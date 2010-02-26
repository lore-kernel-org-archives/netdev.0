From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to drvinfo
 and return it
Date: Fri, 26 Feb 2010 08:59:22 -0500
Message-ID: <4B87D3BA.7050404@garzik.org>
References: <20100226115355.20213.59254.stgit@localhost.localdomain> <4B87D31B.4000001@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010400080505010801070201"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:40055 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936288Ab0BZN7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:59:24 -0500
Received: by ywh35 with SMTP id 35so43577ywh.4
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 05:59:24 -0800 (PST)
In-Reply-To: <4B87D31B.4000001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010400080505010801070201
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 02/26/2010 08:56 AM, Jeff Garzik wrote:
> However, perhaps consider the following patch for returning n-tuple
> count, for four reasons:
>
> 1) space in ethtool_drvinfo is limited
>
> 2) the patch below permits trivial string set addition, without
> ABI changes beyond adding a new ETH_SS_xxx constant.
>
> 3) the patch below permits direct access to ops->get_sset_count(),
> rather than implicit access via ethtool_drvinfo
>
> 4) ethtool_drvinfo interface does not permit indication of
> ops->get_sset_count() failure, versus returning zero value. The
> patch below does so, via output sset_mask.
>
> WARNING: this patch is compile-tested only.
>
> NOTE: I added a cosmetic fix to ETHTOOL_[GS]RXNTUPLE constants, making
> their indentation consistent with the rest of the list of constants.
>
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


With, perhaps, a note like the attached as a reminder to folks about 
future additions.


--------------010400080505010801070201
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patch"

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2V0aHRvb2wuYyBiL25ldC9jb3JlL2V0aHRvb2wuYwpp
bmRleCAzMWIxZWRkLi5lMzc2ZThjIDEwMDY0NAotLS0gYS9uZXQvY29yZS9ldGh0b29sLmMK
KysrIGIvbmV0L2NvcmUvZXRodG9vbC5jCkBAIC0yMTIsNiArMjEyLDkgQEAgc3RhdGljIG5v
aW5saW5lIGludCBldGh0b29sX2dldF9kcnZpbmZvKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYs
IHZvaWQgX191c2VyICp1c2UKIAlpbmZvLmNtZCA9IEVUSFRPT0xfR0RSVklORk87CiAJb3Bz
LT5nZXRfZHJ2aW5mbyhkZXYsICZpbmZvKTsKIAorCS8qIHRoaXMgbWV0aG9kIG9mIG9idGFp
bmluZyBzdHJpbmcgc2V0IGluZm8gaXMgZGVwcmVjYXRlZDsKKwkgKiBjb25zaWRlciB1c2lu
ZyBFVEhUT09MX0dTU0VUX0lORk8gaW5zdGVhZAorCSAqLwogCWlmIChvcHMtPmdldF9zc2V0
X2NvdW50KSB7CiAJCWludCByYzsKIAo=
--------------010400080505010801070201--
