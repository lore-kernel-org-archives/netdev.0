From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Tue, 17 Apr 2007 18:36:14 +0800
Message-ID: <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
References: <200704091146.32346.rgetz@blackfin.uclinux.org>
	 <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com>
	 <200704101952.05380.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_62647_33102637.1176806174833"
Cc: "David Howells" <dhowells@redhat.com>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Robin Getz" <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:17776 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbXDQKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 06:36:15 -0400
Received: by nz-out-0506.google.com with SMTP id s1so1444027nze
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 03:36:15 -0700 (PDT)
In-Reply-To: <200704101952.05380.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_62647_33102637.1176806174833
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 4/11/07, Robin Getz <rgetz@blackfin.uclinux.org> wrote:
> On Tue 10 Apr 2007 08:55, David Howells pondered:
> > Looking at alloc_pg_vec() in af_packet.c, I will place my bets on the
> > latter case.  I don't know that this is a problem; it depends on how things
> > work, and that I don't know offhand.  If someone can give me a simple test
> > program, I would be able to evaluate it better.
>
> Hmm - the only think I have used in the past is tcpdump/libpcap from
> http://public.lanl.gov/cpw/
>
> Documentation/networking/packet_mmap.txt also seems to be a little dated, but
> does have some code snippets if you wanted to make something lightweight...
>
> Does anyone else on netdev have a small test app?
>
Here, in the attachment I wrote a small test app. Please correct if
there is anything wrong, and feel free to improve it.

-Aubrey

------=_Part_62647_33102637.1176806174833
Content-Type: application/x-gzip; name=packet-mmap.tar.gz
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f0m7e0kj
Content-Disposition: attachment; filename="packet-mmap.tar.gz"

H4sIAP2eJEYAA+2V62+bSBDA/RX+ilFyraABGxxM0qSuzkdJatUv4UQ53UMI48VZFQPlETV31//9
ZsGJX/TuS5qrdPuTEMvszOzszOySeP5HkqvLpZe0Gt8IDTnpdNhbP+lo5bduGOV7RUPXTB05OTbM
hqa3DfO4AZ1vFdAmRZZ7KUDDK2Ypuf8nPZJmzxHQ85Js1H/ofSQBDclTr8EKbFb1rq1/xzQe6m+a
bF439HanAdpTB1LH/7z+ljOeTl1rPJz0B3Z3FtBILfyQRsVnVbSs7g/SloK88H3Ruhj0LqddUBer
4RGOb0JFJWHQDsJc9MLwDDJvmYTErfrLZf0ForgvrFNs+qKAC4Ea13lRF/UmhwIGa8lfscK5Mla5
3tgPiRediUK6rDOuMVnMZ6CmgUgj7B/cL5r6dYqQxnH+o/663dTN06bWPD1rif91zTfZPP91mXmK
Nf7l/Lfbhr6+/49P8PybBqrx8/8MHNLID4s5gTcRySk+LRo1b9+Ka7mXJl6LzWyLyzuiRYNVu3xl
kuS3JN2ey+6zVn6fkGxfnMX7rrJ8TuNdUUqjxZ5aSGfbsiKiKN6WJXEY7i+MvV7uWjyc4x8wIuBe
jq7d6fjasey18KfB2PrgTvu/2IKhvTZ35CNHMB5FF05vaFeqbc043ZGj6unareW4o+uhIOimiNdJ
DkuPRtJdTOey+KcoMEkwPxcF3HXh55CvjmdKPgE+55VGRv8gCn7nd1641mWbDeaQlPZFlNFFRObg
32LDv5oVwcqWnos4CECSULcLVRGkyYU76Vkf7CsFpmx7Tu9Ggds8jjLJvnrvTtzeYCDLMrwBTQaM
U0hImsapdLCylw9k9C9gSEUagY7jL3hHkk/NPHFnIeq4LGZcb53V8x2FKH2cHjnrySD1luTBep3o
XYXS+iHfLCckZ6HFSY77ZJsaPG6wervOz67TH10qIFUpkl+iQ6XMbRxIOJZllqq9uOHVZpSYWOiK
AiDSTs5ldqdKmrIq18QZ46J27x38VY1vnP6VrcCwN3Gn73uO/U7BDAroigWslYtjLZtlmcqasq+U
3JEoz1CkrSSPgsl4MOiPmHcc2I7DHFQ9gpOsOaSXCXOtK6DqrFxBnIJES1dAsbQb2QV6dFQVumwV
Ci9WjStDF/VlFmmC5zIPpIPfoqr4D98vmu3P6oECmJpf6e9y1Qs7yn4YZwQrI5d1LJsG9/Plu/pZ
cjgcDofD4XA4HA6Hw+FwOBwOh8PhcDjfOX8Do0m3jgAoAAA=
------=_Part_62647_33102637.1176806174833--
