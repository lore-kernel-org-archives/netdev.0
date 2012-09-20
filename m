From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: New commands to configure IOV features
Date: Wed, 19 Sep 2012 17:19:47 -0700
Message-ID: <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com>
References: <5003DC9B.8000706@broadcom.com>
	<5005BD00.4090106@redhat.com>
	<5005D45D.1040302@genband.com>
	<20120717.141153.46613285253481776.davem@davemloft.net>
	<500978C7.5050004@genband.com>
	<50097FBD.9080202@redhat.com>
	<1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	<5009B186.6000806@genband.com>
	<1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	<5009ECDF.4090305@genband.com>
	<500D59BF.9040006@redhat.com>
	<500D6932.8090306@genband.com>
	<20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	<C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	<5059A767.2090307@broadcom.com>
	<20120919085306.00006af9@unknown>
	<1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com>
	<CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com>
	<1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015175884fcc409db04ca17144e
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0015175884fcc409db04ca17144e
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Sep 19, 2012 at 3:46 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2012-09-19 at 15:17 -0700, Yinghai Lu wrote:
>> +max_vfs_store(struct device *dev, struct device_attribute *attr,
>> +                const char *buf, size_t count)
>> +{
>> +       unsigned long val;
>> +       struct pci_dev *pdev = to_pci_dev(dev);
>> +
>> +       if (strict_strtoul(buf, 0, &val) < 0)
>> +               return -EINVAL;
>> +
>> +       pdev->max_vfs = val;
>> +
>> +       return count;
>> +}
> [...]
>
> Then what would actually trigger creation of the VFs?  There's no way we
> can assume that some sysfs attribute will be written before the PF
> driver is loaded (what if it's built-in?).  I thought the idea was to
> add a driver callback that would be called when the sysfs attribute was
> written.

could just stop the device and add it back again?

just like updated patch.

Thanks

Yinghai

--0015175884fcc409db04ca17144e
Content-Type: application/octet-stream; name="sriov_xxx.patch"
Content-Disposition: attachment; filename="sriov_xxx.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h7b45qci0

U3ViamVjdDogW1BBVENIXSBQQ0k6IEFkZCBtYXhfdmZzIGluIHN5c2ZzIHBlciBwY2kgZGV2aWNl
IHdoZXJlIHN1cHBvcnRzCgpkcml2ZXIgbGF0ZXIgbmVlZCB0byBjaGVjayBkZXYtPm1heF92ZnMg
aW4gL3N5cwoKU2lnbmVkLW9mZi1ieTogWWluZ2hhaSBMdSA8eWluZ2hhaUBrZXJuZWwub3JnPgoK
LS0tCiBkcml2ZXJzL3BjaS9wY2ktc3lzZnMuYyB8ICAgNTcgKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrCiBkcml2ZXJzL3BjaS9yZW1vdmUuYyAgICB8ICAg
IDIgLQogaW5jbHVkZS9saW51eC9wY2kuaCAgICAgfCAgICAyICsKIDMgZmlsZXMgY2hhbmdlZCwg
NjAgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKSW5kZXg6IGxpbnV4LTIuNi9kcml2ZXJz
L3BjaS9wY2ktc3lzZnMuYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9kcml2ZXJzL3Bj
aS9wY2ktc3lzZnMuYworKysgbGludXgtMi42L2RyaXZlcnMvcGNpL3BjaS1zeXNmcy5jCkBAIC00
NTksNiArNDU5LDU4IEBAIGJvb3RfdmdhX3Nob3coc3RydWN0IGRldmljZSAqZGV2LCBzdHJ1Y3QK
IH0KIHN0cnVjdCBkZXZpY2VfYXR0cmlidXRlIHZnYV9hdHRyID0gX19BVFRSX1JPKGJvb3Rfdmdh
KTsKIAorc3RhdGljIHNzaXplX3QKK21heF92ZnNfc2hvdyhzdHJ1Y3QgZGV2aWNlICpkZXYsIHN0
cnVjdCBkZXZpY2VfYXR0cmlidXRlICphdHRyLCBjaGFyICpidWYpCit7CisJc3RydWN0IHBjaV9k
ZXYgKnBkZXYgPSB0b19wY2lfZGV2KGRldik7CisKKwlyZXR1cm4gc3ByaW50ZihidWYsICIldVxu
IiwgcGRldi0+bWF4X3Zmcyk7Cit9CisKK3N0YXRpYyB2b2lkIHJlYmluZF9jYWxsYmFjayhzdHJ1
Y3QgZGV2aWNlICpkZXYpCit7CisJc3RydWN0IHBjaV9kZXYgKnBkZXYgPSB0b19wY2lfZGV2KGRl
dik7CisJaW50IGVycjsKKworCW11dGV4X2xvY2soJnBjaV9yZW1vdmVfcmVzY2FuX211dGV4KTsK
KwlwY2lfc3RvcF9idXNfZGV2aWNlKHBkZXYpOworCWVyciA9IHBjaV9idXNfYWRkX2RldmljZShw
ZGV2KTsKKwlpZiAoIWVycikgeworCQlzdHJ1Y3QgcGNpX2J1cyAqY2hpbGQgPSBwZGV2LT5zdWJv
cmRpbmF0ZTsKKworCQlpZiAoY2hpbGQpIHsKKwkJCXBjaV9idXNfYWRkX2RldmljZXMoY2hpbGQp
OworCQkJaWYgKCFjaGlsZC0+aXNfYWRkZWQpCisJCQkJcGNpX2J1c19hZGRfY2hpbGQoY2hpbGQp
OworCQl9CisJfQorCW11dGV4X3VubG9jaygmcGNpX3JlbW92ZV9yZXNjYW5fbXV0ZXgpOworfQor
c3RhdGljIHNzaXplX3QKK21heF92ZnNfc3RvcmUoc3RydWN0IGRldmljZSAqZGV2LCBzdHJ1Y3Qg
ZGV2aWNlX2F0dHJpYnV0ZSAqYXR0ciwKKwkJIGNvbnN0IGNoYXIgKmJ1Ziwgc2l6ZV90IGNvdW50
KQoreworCXVuc2lnbmVkIGxvbmcgdmFsOworCXN0cnVjdCBwY2lfZGV2ICpwZGV2ID0gdG9fcGNp
X2RldihkZXYpOworCisJaWYgKHN0cmljdF9zdHJ0b3VsKGJ1ZiwgMCwgJnZhbCkgPCAwKQorCQly
ZXR1cm4gLUVJTlZBTDsKKworCXBkZXYtPm1heF92ZnMgPSB2YWw7CisKKwlpZiAocGRldi0+aXNf
YWRkZWQpIHsKKwkJaW50IGVycjsKKwkJZXJyID0gZGV2aWNlX3NjaGVkdWxlX2NhbGxiYWNrKGRl
diwgcmViaW5kX2NhbGxiYWNrKTsKKworCQlpZiAoZXJyKQorCQkJcmV0dXJuIGVycjsKKwl9CisK
KwlyZXR1cm4gY291bnQ7Cit9CitzdHJ1Y3QgZGV2aWNlX2F0dHJpYnV0ZSBtYXhfdmZzX2F0dHIg
PQorCV9fQVRUUihtYXhfdmZzLCAwNjQ0LCBtYXhfdmZzX3Nob3csIG1heF92ZnNfc3RvcmUpOwor
CiBzdGF0aWMgdm9pZAogcGNpX2NvbmZpZ19wbV9ydW50aW1lX2dldChzdHJ1Y3QgcGNpX2RldiAq
cGRldikKIHsKQEAgLTE0MDYsNiArMTQ1OCw3IEBAIGxhdGVfaW5pdGNhbGwocGNpX3N5c2ZzX2lu
aXQpOwogCiBzdGF0aWMgc3RydWN0IGF0dHJpYnV0ZSAqcGNpX2Rldl9kZXZfYXR0cnNbXSA9IHsK
IAkmdmdhX2F0dHIuYXR0ciwKKwkmbWF4X3Zmc19hdHRyLmF0dHIsCiAJTlVMTCwKIH07CiAKQEAg
LTE0MTksNiArMTQ3MiwxMCBAQCBzdGF0aWMgdW1vZGVfdCBwY2lfZGV2X2F0dHJzX2FyZV92aXNp
YmxlCiAJCWlmICgocGRldi0+Y2xhc3MgPj4gOCkgIT0gUENJX0NMQVNTX0RJU1BMQVlfVkdBKQog
CQkJcmV0dXJuIDA7CiAKKwlpZiAoYSA9PSAmbWF4X3Zmc19hdHRyLmF0dHIpCisJCWlmICghcGRl
di0+aXNfcGh5c2ZuKQorCQkJcmV0dXJuIDA7CisKIAlyZXR1cm4gYS0+bW9kZTsKIH0KIApJbmRl
eDogbGludXgtMi42L2luY2x1ZGUvbGludXgvcGNpLmgKPT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQotLS0gbGludXgtMi42
Lm9yaWcvaW5jbHVkZS9saW51eC9wY2kuaAorKysgbGludXgtMi42L2luY2x1ZGUvbGludXgvcGNp
LmgKQEAgLTM1OSw2ICszNTksNyBAQCBzdHJ1Y3QgcGNpX2RldiB7CiAJdW5zaWduZWQgaW50CWJy
b2tlbl9pbnR4X21hc2tpbmc6MTsKIAl1bnNpZ25lZCBpbnQJaW9fd2luZG93XzFrOjE7CS8qIElu
dGVsIFAyUCBicmlkZ2UgMUsgSS9PIHdpbmRvd3MgKi8KIAlwY2lfZGV2X2ZsYWdzX3QgZGV2X2Zs
YWdzOworCXVuc2lnbmVkIGludAltYXhfdmZzOwogCWF0b21pY190CWVuYWJsZV9jbnQ7CS8qIHBj
aV9lbmFibGVfZGV2aWNlIGhhcyBiZWVuIGNhbGxlZCAqLwogCiAJdTMyCQlzYXZlZF9jb25maWdf
c3BhY2VbMTZdOyAvKiBjb25maWcgc3BhY2Ugc2F2ZWQgYXQgc3VzcGVuZCB0aW1lICovCkBAIC04
MTIsNiArODEzLDcgQEAgdTggcGNpX2NvbW1vbl9zd2l6emxlKHN0cnVjdCBwY2lfZGV2ICpkZQog
ZXh0ZXJuIHN0cnVjdCBwY2lfZGV2ICpwY2lfZGV2X2dldChzdHJ1Y3QgcGNpX2RldiAqZGV2KTsK
IGV4dGVybiB2b2lkIHBjaV9kZXZfcHV0KHN0cnVjdCBwY2lfZGV2ICpkZXYpOwogZXh0ZXJuIHZv
aWQgcGNpX3JlbW92ZV9idXMoc3RydWN0IHBjaV9idXMgKmIpOwordm9pZCBwY2lfc3RvcF9idXNf
ZGV2aWNlKHN0cnVjdCBwY2lfZGV2ICpkZXYpOwogZXh0ZXJuIHZvaWQgcGNpX3N0b3BfYW5kX3Jl
bW92ZV9idXNfZGV2aWNlKHN0cnVjdCBwY2lfZGV2ICpkZXYpOwogdm9pZCBwY2lfc3RvcF9yb290
X2J1cyhzdHJ1Y3QgcGNpX2J1cyAqYnVzKTsKIHZvaWQgcGNpX3JlbW92ZV9yb290X2J1cyhzdHJ1
Y3QgcGNpX2J1cyAqYnVzKTsKSW5kZXg6IGxpbnV4LTIuNi9kcml2ZXJzL3BjaS9yZW1vdmUuYwo9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9kcml2ZXJzL3BjaS9yZW1vdmUuYworKysgbGlu
dXgtMi42L2RyaXZlcnMvcGNpL3JlbW92ZS5jCkBAIC01NSw3ICs1NSw3IEBAIHZvaWQgcGNpX3Jl
bW92ZV9idXMoc3RydWN0IHBjaV9idXMgKmJ1cykKIH0KIEVYUE9SVF9TWU1CT0wocGNpX3JlbW92
ZV9idXMpOwogCi1zdGF0aWMgdm9pZCBwY2lfc3RvcF9idXNfZGV2aWNlKHN0cnVjdCBwY2lfZGV2
ICpkZXYpCit2b2lkIHBjaV9zdG9wX2J1c19kZXZpY2Uoc3RydWN0IHBjaV9kZXYgKmRldikKIHsK
IAlzdHJ1Y3QgcGNpX2J1cyAqYnVzID0gZGV2LT5zdWJvcmRpbmF0ZTsKIAlzdHJ1Y3QgcGNpX2Rl
diAqY2hpbGQsICp0bXA7Cg==
--0015175884fcc409db04ca17144e--
