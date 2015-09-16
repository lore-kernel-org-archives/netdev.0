From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Wed, 16 Sep 2015 09:04:15 -0600
Message-ID: <55F984EF.4040503@cumulusnetworks.com>
References: <20150916092447.GA945@swordfish>
 <CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000302050502070203020206"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	richard.alpe@ericsson.com
To: Fabio Estevam <festevam@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000302050502070203020206
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 9/16/15 9:00 AM, Fabio Estevam wrote:
> On Wed, Sep 16, 2015 at 6:24 AM, Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
>
>> added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
>>
>>      net: Add FIB table id to rtable
>>
>>      Add the FIB table id to rtable to make the information available for
>>      IPv4 as it is for IPv6.
>
> I see the same issue here when booting a mx25 ARM processor via NFS.
>
> defconfig is arch/arm/configs/imx_v4_v5_defconfig.
>

I am still not able to reproduce. While I work on a full Cumulus image 
for other test cases here's a patch to try; eagle eye Nikolay noted a 
potential use without init in the maze of goto's.

Thanks,
David

--------------000302050502070203020206
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="res-table-init.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="res-table-init.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3JvdXRlLmMgYi9uZXQvaXB2NC9yb3V0ZS5jCmluZGV4
IGRhNDI3YTRhMzNmZS4uODBmN2M1YjdiODMyIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9yb3V0
ZS5jCisrKyBiL25ldC9pcHY0L3JvdXRlLmMKQEAgLTE3MTIsNiArMTcxMiw3IEBAIHN0YXRp
YyBpbnQgaXBfcm91dGVfaW5wdXRfc2xvdyhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBfX2JlMzIg
ZGFkZHIsIF9fYmUzMiBzYWRkciwKIAkJZ290byBtYXJ0aWFuX3NvdXJjZTsKIAogCXJlcy5m
aSA9IE5VTEw7CisJcmVzLnRhYmxlID0gTlVMTDsKIAlpZiAoaXB2NF9pc19sYmNhc3QoZGFk
ZHIpIHx8IChzYWRkciA9PSAwICYmIGRhZGRyID09IDApKQogCQlnb3RvIGJyZF9pbnB1dDsK
IApAQCAtMTgzNCw2ICsxODM1LDcgQEAgb3V0OglyZXR1cm4gZXJyOwogCVJUX0NBQ0hFX1NU
QVRfSU5DKGluX25vX3JvdXRlKTsKIAlyZXMudHlwZSA9IFJUTl9VTlJFQUNIQUJMRTsKIAly
ZXMuZmkgPSBOVUxMOworCXJlcy50YWJsZSA9IE5VTEw7CiAJZ290byBsb2NhbF9pbnB1dDsK
IAogCS8qCg==
--------------000302050502070203020206--
