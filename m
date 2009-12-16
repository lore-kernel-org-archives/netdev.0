From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH] gianfar: Fix tests of unsigneds in gfar_parse_group()
Date: Wed, 16 Dec 2009 10:34:56 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08D5A@zin33exm22.fsl.freescale.net>
References: <4B27D87D.5070908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Roel Kluin" <roel.kluin@gmail.com>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751732AbZLPFFG@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
>Won't it be better to change types of interruptTransmit, 
>-Receive and -Error in  struct gfar_priv_grp itself. Something 
>like this:
>
>struct gfar_priv_grp {
>....
>-	unsigned int interruptTransmit;
>-	unsigned int interruptReceive;
>-	unsigned int interruptError;
>
>+	unsigned int interruptTransmit;
>+	unsigned int interruptReceive;
>+	unsigned int interruptError;
>....
>}
>

Sorry for my earlier mail, What I meant is something like this:

struct gfar_priv_grp {
....
-	unsigned int interruptTransmit;
-	unsigned int interruptReceive;
-	unsigned int interruptError;

+	int interruptTransmit;
+	int interruptReceive;
+	int interruptError;
....
}

--

Thanks
Sandeep
