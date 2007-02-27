From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 23:21:19 -0700
Message-ID: <e9c3a7c20702262221i4ce5d2c8r4f55ee70d04c7a70@mail.gmail.com>
References: <20070223170527.4ca695b2@freekitty>
	 <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
	 <20070226143127.5c74bec9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jan Engelhardt" <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Nicolas Pitre" <nico@cam.org>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:61509 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932784AbXB0GVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 01:21:20 -0500
Received: by nf-out-0910.google.com with SMTP id o25so80766nfa
        for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 22:21:19 -0800 (PST)
In-Reply-To: <20070226143127.5c74bec9@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/26/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Here is another way to handle the 64 bit divide case.
> It allows full 64 bit divide by adding the support routine
> GCC needs.
>
<snip>

I know ARM already went through the process of removing __udivdi3 support:
http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=2723/2

Copying Russell and Nicolas as a heads up.

--
Dan
