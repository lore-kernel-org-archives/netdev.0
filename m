From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] net/socket: return -EAFNOSUPPORT if net_family_get fails at sock_create and sys_accept
Date: Tue, 29 Apr 2003 06:11:26 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429091126.GZ25361@conectiva.com.br>
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

	Now there are two outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1149, 2003-04-29 06:06:37-03:00, acme@conectiva.com.br
  o net/socket: return -EAFNOSUPPORT if net_family_get fails at sock_create and sys_accept
  
  Thanks to Rusty for spotting this one, if the net family module is not there
  anymore (or is going away at that time) it is not supported, not busy.


 socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Tue Apr 29 06:08:28 2003
+++ b/net/socket.c	Tue Apr 29 06:08:28 2003
@@ -1091,7 +1091,7 @@
 
 	sock->type  = type;
 
-	i = -EBUSY;
+	i = -EAFNOSUPPORT;
 	if (!net_family_get(family))
 		goto out_release;
 
@@ -1288,7 +1288,7 @@
 	if (err)
 		goto out_release;
 
-	err = -EBUSY;
+	err = -EAFNOSUPPORT;
 	if (!net_family_get(sock->ops->family))
 		goto out_release;
 

===================================================================


This BitKeeper patch contains the following changesets:
1.1149
## Wrapped with gzip_uu ##


M'XL(  Q!KCX  ^U476^;,!1]CG_%E?JR:878!D-@RM3/?:C3&J7M<^0ZEX :
M<&0[K9#X\3/)UN^MZM3'@86!>WSN\;T'=N#"HLD'4M5(=N"KMBX?*-V@<M6U
M#)6NPTOC U.M?6!8ZAJ'!R?#!EW 0T%\9"*=*N$:C<T'+(QNW[AVA?E@>OSE
MXOO^E)#Q& Y+V2SP#!V,Q\1I<RV7<[LG7;G43>B,;&R-;I.SNX5VG%+N3\'2
MB(JD8PF-TTZQ.6,R9CBG/!XE,>GE[SV6_9 EHC'/Z$A$(NNB$8LY.0(6,A9G
M0*,AC8?<WR2Y'U$:T"BG%)YEA0\, DH.X&UW<$@4:/!U'5JMKM#E8-"M30/!
M\?[G'Z=G%Y/)Z?0<JJ+'S I95\MVMO"U+&2UM" =].MFRJ!T"+*9@VWM3"J%
M*^>I_3CWBJZLEPW3M74M%-J 76GGJF8!KJPL^)WN]AE<B7T6V&:!6L_72P0/
M:+3K@P8]G6S:6AN$=Y[&AQ:ZIY$WLNVUN+*_5#6^A\K]7FG7JY4V#N>[F\?+
MM6U#<@)],Q(RN;,'"5YY$$(E)9]>Z,A=;4-UORF92+LD3E/1*5JD/)&%$&EQ
MR3/UO &>$&V=E=&$BRZ*!$TV;K^/>MGPKQ?W!\\_)RYE$4\\4<1COK6]$(]-
MS\7?3<\AX/]-_W:FW_CD% )SLQG>Q),'EOF'C^"(T2P&1K[]F@<5C!]6\J/'
C\(QM,-MY@,8\1=W^Q%6)ZLJNZ['$$:JLD.0G4.(7&C$&    
 
