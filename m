From: Hannes Reinecke <hare@suse.de>
Subject: Re: linux-next: Tree for September 13 (3c509)
Date: Mon, 15 Sep 2008 16:27:24 +0200
Message-ID: <48CE70CC.7020901@suse.de>
References: <20080913162344.ab395285.sfr@canb.auug.org.au> <20080914141757.899f71eb.randy.dunlap@oracle.com> <20080915141149.GA10002@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070005040208050009000409"
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53606 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476AbYIOO11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 10:27:27 -0400
In-Reply-To: <20080915141149.GA10002@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070005040208050009000409
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Adrian,

Adrian Bunk wrote:
> On Sun, Sep 14, 2008 at 02:17:57PM -0700, Randy Dunlap wrote:
>> drivers/net/3c509.c fails (CONFIG_PM=y) with:
>>
>> drivers/built-in.o:(.data+0x7dcc): undefined reference to `el3_resume'
>> drivers/built-in.o:(.data+0x7e08): undefined reference to `el3_resume'
>>
>> It seems that this function does not exist in the source file.
> 
> 
> It got removed by:
> 
> 
> commit 107aeb9753159da848f066b26557f0aaab900a90
> Author: Hannes Reinecke <hare@suse.de>
> Date:   Wed Sep 10 14:16:04 2008 +0200
> 
>     Driver core: Use dev_get_drvdata() accessors
>     
>     Deprecated direct access to the ->driver_data field and
>     use accessors throughout.
>     
>     Signed-off-by: Hannes Reinecke <hare@suse.de>
>     Cc: Kay Sievers <kay.sievers@vrfy.org>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
Sorry. Here it is again.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)

--------------070005040208050009000409
Content-Type: text/plain;
 name="3c509-readd-el3_resume"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="3c509-readd-el3_resume"

UmUtYWRkIGVsM19yZXN1bWUgdG8gM2M1MDkKCkluIGNvbW1pdCAxMDdhZWI5NzUzMTU5ZGE4
NDhmMDY2YjI2NTU3ZjBhYWFiOTAwYTkwCmVsM19yZXN1bWUoKSBmcm9tIGRyaXZlcnMvbmV0
LzNjNTA5LmMgYWNjaWRlbnRhbGx5IGdvdApyZW1vdmVkLiBSZS1hZGQgaXQuCgpTaWduZWQt
b2ZmLWJ5OiBIYW5uZXMgUmVpbmVja2UgPGhhcmVAc3VzZS5kZT4KCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC8zYzUwOS5jIGIvZHJpdmVycy9uZXQvM2M1MDkuYwppbmRleCBiMzNmN2Q5
Li42YWNlMjIwIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC8zYzUwOS5jCisrKyBiL2RyaXZl
cnMvbmV0LzNjNTA5LmMKQEAgLTE0OTMsNiArMTQ5MywxNSBAQCBlbDNfY29tbW9uX3Jlc3Vt
ZShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogCXJldHVybiAwOwogfQogCitzdGF0aWMgaW50
CitlbDNfcmVzdW1lKHN0cnVjdCBkZXZpY2UgKnBkZXYpCit7CisJc3RydWN0IG5ldF9kZXZp
Y2UgKmRldjsKKworCWRldiA9IGRldl9nZXRfZHJ2ZGF0YShwZGV2KTsKKwlyZXR1cm4gZWwz
X2NvbW1vbl9yZXN1bWUoZGV2KTsKK30KKwogI2VuZGlmIC8qIENPTkZJR19QTSAqLwogCiBt
b2R1bGVfcGFyYW0oZGVidWcsaW50LCAwKTsK
--------------070005040208050009000409--
