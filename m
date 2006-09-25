From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 00/03][RESUBMIT] net: EtherIP tunnel driver
Date: Mon, 25 Sep 2006 16:49:14 -0400
Message-ID: <451840CA.5060901@hp.com>
References: <20060923120704.GA32284@zlug.org> <20060923121327.GH30245@lug-owl.de> <1159015118.5301.19.camel@jzny2> <20060923132736.GA345@zlug.org> <200609250107.k8P17h8A019714@turing-police.cc.vt.edu> <20060925083249.GC23028@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, jamal <hadi@cyberus.ca>,
	Jan-Benedict Glaw <jbglaw@lug-owl.de>,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:33166 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751109AbWIYUtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 16:49:21 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060925083249.GC23028@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Roedel wrote:
>> Is there something in the RFC that suggests that a byte order other than
>> 'network order' is possible/acceptable there?
> 
> No. The RFC states nothing at all about byte- or bitorder. That is why
> the RFC is ambigious at this point.

RFC 791 (IPv4) Appendix B does give instructions on byte ordering for 
all IPv4 headers and data, and RFC 791 is listed in the References for 
RFC 3378.  I noticed this is only Informational, not a Standards track 
document, so I guess the non-interoperable implementations kind of go 
with the territory.

-Brian
