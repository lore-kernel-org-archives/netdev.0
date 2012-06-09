From: Paul Pluzhnikov <ppluzhnikov@google.com>
Subject: Re: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly (trivial)
Date: Fri, 8 Jun 2012 21:14:19 -0700
Message-ID: <CALoOobNbt0Kbea8gHdNkQFa0+ydpH++6ND+fOBGvy5Rmf=_QpA@mail.gmail.com>
References: <20111229183002.9B4F4190B09@elbrus2.mtv.corp.google.com>
 <alpine.LNX.2.00.1202032232320.25026@pobox.suse.cz> <CALoOobMSXp4x_+En2gyHmpXcxq=sECQvMZN1LX_j3Yve7Ha6Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d04451803a8bdcc04c2025b49
Cc: netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57554 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2FIEOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 00:14:52 -0400
Received: by wibhn6 with SMTP id hn6so1135282wib.1
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 21:14:51 -0700 (PDT)
In-Reply-To: <CALoOobMSXp4x_+En2gyHmpXcxq=sECQvMZN1LX_j3Yve7Ha6Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d04451803a8bdcc04c2025b49
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Mar 6, 2012 at 4:14 PM, Paul Pluzhnikov <ppluzhnikov@google.com> wrote:
> Ping?
>
> I am attaching the patch again so it doesn't get mangled by quoting
> and is easier to apply.

Ping? Ping?

I thought the patch has been applied, and stopped pinging it.
But it appears that it never did get applied :-(

Thanks,

On Thu, Dec 29, 2011 at 10:30 AM, Paul Pluzhnikov
<ppluzhnikov@google.com> wrote:
>
> Using linux/tcp.h from C++ results in:
>
> cat t.cc
>
> #include <linux/tcp.h>
> int main() { }
>
> g++ -c t.cc
>
> In file included from t.cc:1:
> /usr/include/linux/tcp.h:72: error: '__u32 __fswab32(__u32)' cannot appear in a constant-expression
> /usr/include/linux/tcp.h:72: error: a function call cannot appear in a constant-expression
> ...


-- 
Paul Pluzhnikov

--f46d04451803a8bdcc04c2025b49
Content-Type: text/plain; charset=US-ASCII; name="linux-tcp_h-patch-20111229.txt"
Content-Disposition: attachment; filename="linux-tcp_h-patch-20111229.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gzhm7aqn0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvdGNwLmggYi9pbmNsdWRlL2xpbnV4L3RjcC5oCmlu
ZGV4IDdmNTllZTkuLjYzMzM0ZjcgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGNwLmgKKysr
IGIvaW5jbHVkZS9saW51eC90Y3AuaApAQCAtNjksMTYgKzY5LDE2IEBAIHVuaW9uIHRjcF93b3Jk
X2hkciB7CiAjZGVmaW5lIHRjcF9mbGFnX3dvcmQodHApICggKCh1bmlvbiB0Y3Bfd29yZF9oZHIg
KikodHApKS0+d29yZHMgWzNdKSAKIAogZW51bSB7IAotCVRDUF9GTEFHX0NXUiA9IF9fY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCi0JVENQX0ZMQUdfRUNFID0gX19jcHVfdG9fYmUzMigweDAwNDAw
MDAwKSwKLQlUQ1BfRkxBR19VUkcgPSBfX2NwdV90b19iZTMyKDB4MDAyMDAwMDApLAotCVRDUF9G
TEFHX0FDSyA9IF9fY3B1X3RvX2JlMzIoMHgwMDEwMDAwMCksCi0JVENQX0ZMQUdfUFNIID0gX19j
cHVfdG9fYmUzMigweDAwMDgwMDAwKSwKLQlUQ1BfRkxBR19SU1QgPSBfX2NwdV90b19iZTMyKDB4
MDAwNDAwMDApLAotCVRDUF9GTEFHX1NZTiA9IF9fY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCi0J
VENQX0ZMQUdfRklOID0gX19jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKLQlUQ1BfUkVTRVJWRURf
QklUUyA9IF9fY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCi0JVENQX0RBVEFfT0ZGU0VUID0gX19j
cHVfdG9fYmUzMigweEYwMDAwMDAwKQorCVRDUF9GTEFHX0NXUiA9IF9fY29uc3RhbnRfY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCisJVENQX0ZMQUdfRUNFID0gX19jb25zdGFudF9jcHVfdG9fYmUz
MigweDAwNDAwMDAwKSwKKwlUQ1BfRkxBR19VUkcgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4
MDAyMDAwMDApLAorCVRDUF9GTEFHX0FDSyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDEw
MDAwMCksCisJVENQX0ZMQUdfUFNIID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDgwMDAw
KSwKKwlUQ1BfRkxBR19SU1QgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4MDAwNDAwMDApLAor
CVRDUF9GTEFHX1NZTiA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCisJVENQ
X0ZMQUdfRklOID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKKwlUQ1BfUkVT
RVJWRURfQklUUyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCisJVENQX0RB
VEFfT0ZGU0VUID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweEYwMDAwMDAwKQogfTsgCiAKIC8q
Cg==
--f46d04451803a8bdcc04c2025b49--
