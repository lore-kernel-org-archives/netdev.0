From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: eth: realtek: atp: checkpatch errors and warnings
 corrected
Date: Tue, 4 Nov 2014 10:19:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E71E4@AcuExch.aculab.com>
References: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com>
 <1415040686.17743.31.camel@perches.com> <5457D2DF.5000508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Roberto Medina' <robertoxmed@gmail.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35469 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753055AbaKDKWp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 05:22:45 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08393-02 for <netdev@vger.kernel.org>;
 Tue,  4 Nov 2014 10:22:34 +0000 (GMT)
In-Reply-To: <5457D2DF.5000508@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roberto Medina
> On 11/03/2014 07:51 PM, Joe Perches wrote:
> >
> > Some ancient drivers could be regarded as neolithic
> > curiosities that never need updating.  This may be one.
> >
> > But if you really want to change it, could you please
> > make sure that objdiff shows no changes?
> >
> 
> I see some changes with objdiff, maybe this is caused by the include
> file that I changed to linux/io.h instead of asm/io.h
> 
> ---
> /home/vov/Git/linux-next/.tmp_objdiff/a641d0e/drivers/net/ethernet/realtek/atp.dis
> 2014-11-03 19:59:18.723954900 +0100
> +++
> /home/vov/Git/linux-next/.tmp_objdiff/5f19b70/drivers/net/ethernet/realtek/atp.dis
> 2014-11-03 20:00:34.133954217 +0100
> @@ -1753,9 +1753,8 @@
>   	...
>   :	e3 0a                	jrcxz  4c4 <__gcov_.atp_probe1+0x14>
>   :	00 00                	add    %al,(%rax)
> -:	e2 e2                	loop   4a0 <__gcov_.atp_init+0x20>
> -:	9c                   	pushfq
> -:	9a                   	(bad)
> +:	4b b4 98             	rex.WXB mov $0x98,%r12b
> +:	ac                   	lods   %ds:(%rsi),%al
>   :	67 2f                	addr32 (bad)
>   :	e4 e3                	in     $0xe3,%al
>   :	00 00                	add    %al,(%rax)

That code (and all the ones below) are gibberish, neither the old or new
sequences make any sense.

Almost as though you used the wrong instruction set!

	David
