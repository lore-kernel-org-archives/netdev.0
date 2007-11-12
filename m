From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Resend][PATCH 01/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 17:22:48 -0500
Message-ID: <4738D238.8050105@hp.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <4738CF78.6030804@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC21@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:57892 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755226AbXKLWWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 17:22:49 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC21@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fred

Templin, Fred L wrote:
> Vlad,
> 
> Yes, I was breaking into multiples to ease review only.
> The "[PATCH 01/04] ... (5)" thread includes the complete
> reviewable and patchable final text in 4 files. In my
> next message, I will put the entire patchfile as inline
> text. (The "[PATCH 01/01] ... (5)" for 'iproute2' is
> already complete.)
> 

Ok, thanks for the explanation.  One questions is though why
do we need all the #if defines() throughout the file?

Most distros end up enabled almost everything anyway.  Looking
at the code, there is really nothing that needs a conditional.
Removing the conditionals would make things cleaner.

Just some of my thoughts.

Thanks
-vlad
