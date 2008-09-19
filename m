From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Fri, 19 Sep 2008 13:15:38 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0809191311130.29711@cliff.in.clinika.pl>
References: <Pine.LNX.4.55.0809171104290.17103@cliff.in.clinika.pl>
 <20080917.222350.41199051.anemo@mba.ocn.ne.jp>
 <Pine.LNX.4.55.0809171501450.17103@cliff.in.clinika.pl>
 <20080918.002705.78730226.anemo@mba.ocn.ne.jp>
 <Pine.LNX.4.55.0809171917580.17103@cliff.in.clinika.pl>
 <20080918220734.GA19222@linux-mips.org> <Pine.LNX.4.55.0809190112090.22686@cliff.in.clinika.pl>
 <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org>
 <20080919120752.GA19877@linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, u1@terran.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:63131 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753814AbYISMQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 08:16:16 -0400
In-Reply-To: <20080919120752.GA19877@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008, Ralf Baechle wrote:

> +	beqz	t7, 1f			/* odd buffer alignment? */
> +	 lui	v1, 0x00ff

 Well, .set reorder to move something from before the branch would have 
been a little bit better for the common aligned case. ;)  There is nothing 
special about branch delay slots in the whole epilogue, so one from just 
before the return might simply be relocated here.

  Maciej
