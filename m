From: "Duane Griffin" <duaneg@dghda.com>
Subject: Re: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Tue, 10 Jul 2007 11:23:15 +0100
Message-ID: <e9e943910707100323o35cb0316i5d3f21584ad8e4ae@mail.gmail.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
	 <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Matt Mackall" <mpm@selenic.com>,
	"Keiichi Kii" <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	"Joel Becker" <joel.becker@oracle.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>
To: "Satyam Sharma" <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:35578 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757278AbXGJKXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 06:23:17 -0400
Received: by nz-out-0506.google.com with SMTP id s18so961319nze
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 03:23:16 -0700 (PDT)
In-Reply-To: <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/07, Satyam Sharma <ssatyam@cse.iitk.ac.in> wrote:
> +       /* Avoid taking lock and disabling interrupts unnecessarily */
> +       if (unlikely(list_empty(&target_list)))
> +               return;

Is the unlikely a good idea here? Not having any targets may be
unusual but it isn't ridiculous. It might even be a sensible default
for distros. My (very limited) understanding of unlikely is that it
could impose a very large penalty in that case and would make a very
marginal difference at best in the common case.

Cheers,
Duane.

-- 
"I never could learn to drink that blood and call it wine" - Bob Dylan
