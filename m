From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] af_llc: initialize ->owner in llc_ui_family_ops
Date: Sun, 27 Apr 2003 12:46:24 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030427154624.GG15637@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	Now there are four outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1126, 2003-04-27 12:33:16-03:00, acme@conectiva.com.br
  o af_llc: initialize ->owner in llc_ui_family_ops
  
  The previous changeset for llc was enough when the BSD sockets interface
  for AF_LLC was not selected, but this changeset is needed when it is
  selected.


 af_llc.c |    1 +
 1 files changed, 1 insertion(+)


diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	Sun Apr 27 12:35:25 2003
+++ b/net/llc/af_llc.c	Sun Apr 27 12:35:25 2003
@@ -1013,6 +1013,7 @@
 static struct net_proto_family llc_ui_family_ops = {
 	.family = PF_LLC,
 	.create = llc_ui_create,
+	.owner	= THIS_MODULE,
 };
 
 static struct proto_ops llc_ui_ops = {

===================================================================


This BitKeeper patch contains the following changesets:
1.1126
## Wrapped with gzip_uu ##


M'XL( +WXJSX  ^V4;6^;,!#'7\>?XJ2^7$/\@"%!2I4^;:V:J572OD:.N114
M@BOL)&K%AY\A6[MUD:9->3DP2/A\_[OS_? 1/%BLDY[2*R1'<&6L2WK:5*A=
ML5&!-JM@47O#S!AO&.1FA8.SFT&%KL\#2;SE3CF=PP9KF_18(-YFW,LS)KW9
MY9>'Z>F,D/$8SG-5/>(<'8S'Q)EZH\K,3I3+2U,%KE:57:'K8C9O2QM.*?>W
M9+&@,FI81,.XT2QC3(4,,\K#8122-OW)Q[1_51$TY#&3_BT;$5+&R 6P@#$>
M 14#&@YX#(PG0B0LZE.14 I[5>$3@SXE9W#8"LZ)!@-JF9:E3J"H"E>HLGA%
MZ)^8;86UGP)O2M=%NE2KHGQ)S;/U/G[<YPC/-6X*L[:@N[C6;_+2U*T';)4%
MK,SZ,8=MCA4XO_QL?@'6Z"=TU@L[K)=*HY=J?4X_I]/I>>=6&0<62U\_9L>P
M6#OO7/P<PW]4B!EF.^FBG?$R/WP"<@,BE#$C=^_=)_V_O BABI*3_>UH/(H#
M7V;[I&U)@=[MN!2,"B%YV @11[[GPU',N6;A4"Y&B/@'N5TG=F+?T1&"\D;2
M*.(=SA]7ME0?-D6RT'4YJ3'+E>N@VI^<H!$;T2B433BB0G9<"_F1:LK_4WTX
MJG<8W$*_WG;#4WKW&Q'_0/HUHTP"([V@VY_>&.ZOKN?IU]N+A^GE\?MYJW/4
43W:]&F<>&C7T_\<W]+LJJ\H%    
 
