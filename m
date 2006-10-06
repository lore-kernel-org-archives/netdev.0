From: Peter Bieringer <pb@bieringer.de>
Subject: Re: [PATCH 01/02] net/ipv6: seperate sit driver to extra module
Date: Fri, 06 Oct 2006 13:44:49 +0200
Message-ID: <452641B1.3000203@bieringer.de>
References: <20061006093402.GA12460@zlug.org> <87d595lln3.fsf@willow.rfc1149.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.aerasec.de ([212.18.21.179]:18305 "EHLO smtp4.aerasec.de")
	by vger.kernel.org with ESMTP id S1751222AbWJFLox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 07:44:53 -0400
To: Samuel Tardieu <sam@rfc1149.net>
In-Reply-To: <87d595lln3.fsf@willow.rfc1149.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samuel Tardieu schrieb:
>>>>>> "Joerg" == Joerg Roedel <joro-lkml@zlug.org> writes:
>
> Joerg> this is the submit of the patch discussed yesterday to compile
> Joerg> the sit driver as a seperate module.
>
> Your patch looks ok to me, but given that many people won't need sit,
> why is it enabled by default? Omitting it would save 10k of kernel
> text on x86 and people will see the new kernel configuration option
> anyway and will enable it if needed.

At least if set to "n" don't forget to alert the distributors (Red Hat,
etc.) to renable this. Otherwise, many clients which using 6to4 will fail...

Just my 2 cents,

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
