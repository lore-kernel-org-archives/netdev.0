From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] atm/eni: use skb_queue_walk, not open coded equivalent
Date: Mon, 18 Aug 2003 00:08:59 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818030859.GB2853@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, chas@cmf.nrl.navy.mil
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Chas, David,

	Pleae consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	There is just this trivial outstanding changeset there.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1210, 2003-08-17 23:12:31-03:00, acme@conectiva.com.br
  o atm/eni: use skb_queue_walk, not open coded equivalent


 eni.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)


diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	Sun Aug 17 23:22:24 2003
+++ b/drivers/atm/eni.c	Sun Aug 17 23:22:24 2003
@@ -2019,8 +2019,7 @@
 	 * segmentation buffer descriptors of this VCC.
 	 */
 	tasklet_disable(&eni_dev->task);
-	for (skb = eni_dev->tx_queue.next; skb !=
-	    (struct sk_buff *) &eni_dev->tx_queue; skb = skb->next) {
+	skb_queue_walk(&eni_dev->tx_queue, skb) {
 		unsigned long dsc;
 
 		if (ATM_SKB(skb)->vcc != vcc) continue;

===================================================================


This BitKeeper patch contains the following changesets:
1.1210
## Wrapped with gzip_uu ##


M'XL( & X0#\  \U476O;,!1]MG[%A<+86&WK2OZ&E&SMV$8'"QE]&B/(LA('
MQU9KR^G&_.,KIZ-IUXZPLH=)0K)UQ=&YYQYT!!>=:C-'R%J1(_B@.Y,Y4C=*
MFO56>%+77M[:P%QK&_!+72L_K_RN6N3]<NDR+R(V.A-&EK!5;9<YZ/&['?/C
M4F7._-W[BT]OYH1,)G!:BF:EOB@#DPDQNMV*3=%-A2DWNO%,*YJN5F9W[W!W
M=&"4,MM#C#D-HP$C&L2#Q )1!*@*RH(D"O9H(TE/=\7&T^WJ(0RG"<8,@S1(
M!Y[:3W(&Z"%#"I3[-/$Q!L8S9!E'E_*,4AB5F?ZN"+Q&<"EY"_\VA5,B08,P
MM:^:=09]IZ"K\L55KWJUN!:;ZA@:;4!?J@:D+E0!ZJJWK#:J,>0<>,IX2&9[
MD8G[EXT0*B@Y.9!6T:['6ON_B'KR7GH!Q<2F%X?I$&"T9#3'-)=YFJKX:2F?
M1AL+E5#DE"4#9R&+=^YY=/2PBY[)E:Q:M9I6K1;E"/-U_/WV)ZHQ1V9G9 ./
M>8*WGDKO.<K:B68L.>@H]M\Y:B?]9W#;Z]VP#ID]KL(S;'9FN3-@Y*-=.2!Q
M'K)Z^<("+PJU=4_,]]O]XY'X*_BY?V]DJ635]?5$Y&D4<A&2&PT1527.!   
 
