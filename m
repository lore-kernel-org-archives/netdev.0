From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 18 May 2016 11:51:25 -0700
Message-ID: <CA+55aFxTXem=w71Q4pJCgeypqLzt+zk6KqoPM547usNDYxAjpg@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
	<CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
	<1463568714.13625.18.camel@intel.com>
	<CAAA5faF=SxqCt0yDTbPyUoc3gFD--_co+fRj2Jfuy=whEQvcBQ@mail.gmail.com>
	<1463575273.13625.23.camel@intel.com>
	<CAAA5faHtbt8oyKEQOJ+NMBKR24b7Nvm6uJ2qZid1sWY58e7f+A@mail.gmail.com>
	<1463581411.29999.1.camel@intel.com>
	<CA+55aFxThzV3myrHv0XZbubEdGhg5=rGE6dK=+L1ddc9sufdCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c11bef032bcb7053322583a
Cc: "reinoudkoornstra@gmail.com" <reinoudkoornstra@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxThzV3myrHv0XZbubEdGhg5=rGE6dK=+L1ddc9sufdCQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c11bef032bcb7053322583a
Content-Type: text/plain; charset=UTF-8

On Wed, May 18, 2016 at 11:45 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> From what I can tell, there's a merge bug in commit 909b27f70643,
> where David seems to have lost some of the changes to
> iwl_mvm_set_tx_cmd().
>
> I do not know if that's the reason for the problem I see. But I will test.

Yes. The attached patch that fixes the incorrect merge seems to fix
things for me.

That should mean that the assumption that this problem existed in v4.6
too was wrong, because the incorrect merge came in later. I think
Luciano mis-understood "v4.6+" to mean plain v4.6.

Reinoud Koornstra, does this patch fix things for you too?

                       Linus

--94eb2c11bef032bcb7053322583a
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iod85dxa0

IGRyaXZlcnMvbmV0L3dpcmVsZXNzL2ludGVsL2l3bHdpZmkvbXZtL3R4LmMgfCAzICsrLQogMSBm
aWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBh
L2RyaXZlcnMvbmV0L3dpcmVsZXNzL2ludGVsL2l3bHdpZmkvbXZtL3R4LmMgYi9kcml2ZXJzL25l
dC93aXJlbGVzcy9pbnRlbC9pd2x3aWZpL212bS90eC5jCmluZGV4IDg4MDIxMDkxN2E2Zi4uYzUz
YWEwZjIyMGUwIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9pbnRlbC9pd2x3aWZp
L212bS90eC5jCisrKyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2ludGVsL2l3bHdpZmkvbXZtL3R4
LmMKQEAgLTIxMSw2ICsyMTEsNyBAQCB2b2lkIGl3bF9tdm1fc2V0X3R4X2NtZChzdHJ1Y3QgaXds
X212bSAqbXZtLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJc3RydWN0IGl3bF90eF9jbWQgKnR4
X2NtZCwKIAkJCXN0cnVjdCBpZWVlODAyMTFfdHhfaW5mbyAqaW5mbywgdTggc3RhX2lkKQogewor
CXN0cnVjdCBpZWVlODAyMTFfdHhfaW5mbyAqc2tiX2luZm8gPSBJRUVFODAyMTFfU0tCX0NCKHNr
Yik7CiAJc3RydWN0IGllZWU4MDIxMV9oZHIgKmhkciA9ICh2b2lkICopc2tiLT5kYXRhOwogCV9f
bGUxNiBmYyA9IGhkci0+ZnJhbWVfY29udHJvbDsKIAl1MzIgdHhfZmxhZ3MgPSBsZTMyX3RvX2Nw
dSh0eF9jbWQtPnR4X2ZsYWdzKTsKQEAgLTI5NCw3ICsyOTUsNyBAQCB2b2lkIGl3bF9tdm1fc2V0
X3R4X2NtZChzdHJ1Y3QgaXdsX212bSAqbXZtLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCXR4X2Nt
ZC0+dHhfZmxhZ3MgPSBjcHVfdG9fbGUzMih0eF9mbGFncyk7CiAJLyogVG90YWwgIyBieXRlcyB0
byBiZSB0cmFuc21pdHRlZCAqLwogCXR4X2NtZC0+bGVuID0gY3B1X3RvX2xlMTYoKHUxNilza2It
PmxlbiArCi0JCSh1aW50cHRyX3QpaW5mby0+ZHJpdmVyX2RhdGFbMF0pOworCQkodWludHB0cl90
KXNrYl9pbmZvLT5kcml2ZXJfZGF0YVswXSk7CiAJdHhfY21kLT5saWZlX3RpbWUgPSBjcHVfdG9f
bGUzMihUWF9DTURfTElGRV9USU1FX0lORklOSVRFKTsKIAl0eF9jbWQtPnN0YV9pZCA9IHN0YV9p
ZDsKIAo=
--94eb2c11bef032bcb7053322583a--
