From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFCv3 08/14] arm64: introduce aarch64_insn_gen_movewide()
Date: Wed, 16 Jul 2014 16:25:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17274D55@AcuExch.aculab.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
 <1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
 <20140716161715.GU29414@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Will Deacon' <will.deacon@arm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58420 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934347AbaGPQ0e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 12:26:34 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26052-04 for <netdev@vger.kernel.org>;
 Wed, 16 Jul 2014 17:26:31 +0100 (BST)
In-Reply-To: <20140716161715.GU29414@arm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon
...
> > +	BUG_ON(imm < 0 || imm > 65535);
> 
> Do this check with masking instead?

The compiler will convert that to a single unsigned comparison.

...
> > +		BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
> > +		       shift != 48);

OTOH I don't think it will convert that to:
		BUG_ON(shift & ~48);

	David
