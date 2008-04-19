From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-git2 fails build (nf_nat_proto_sctp.ko)
Date: Sat, 19 Apr 2008 19:10:38 +0200
Message-ID: <480A278E.60507@trash.net>
References: <200804191329.m3JDTS0m023459@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010001000407090703000105"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Pete Clements <clem@clem.clem-digital.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200804191329.m3JDTS0m023459@clem.clem-digital.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010001000407090703000105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Pete Clements wrote:
> Root device is (3, 1)
> Setup is 11288 bytes (padded to 11776 bytes).
> System is 1162 kB
> CRC 695701be
> Kernel: arch/x86/boot/bzImage is ready  (#4)
>   Building modules, stage 2.
>   MODPOST 132 modules
> ERROR: "crc32c_le" [net/ipv4/netfilter/nf_nat_proto_sctp.ko] undefined!


Sorry about that. We need to select LIBCRC32C.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------010001000407090703000105
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 0c95cd5..2767841 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -259,6 +259,7 @@ config NF_NAT_PROTO_SCTP
 	tristate
 	default NF_NAT && NF_CT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
+	select LIBCRC32C
 
 config NF_NAT_FTP
 	tristate

--------------010001000407090703000105--
