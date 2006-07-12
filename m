From: Kevin Brown <kevin@sysexperts.com>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Tue, 11 Jul 2006 21:09:29 -0700
Message-ID: <44B475F9.2010805@sysexperts.com>
References: <20060703205238.GA10851@deprecation.cyrius.com> <20060707141843.73fc6188@dxpl.pdx.osdl.net> <200607072328.51282.ak@suse.de> <44B46276.5030006@suespammers.org> <121226.1152672894714.SLOX.WebMail.wwwrun@imap-dhs.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony DeRobertis <asd@suespammers.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [67.170.228.241] ([67.170.228.241]:43494 "EHLO sysexperts.com")
	by vger.kernel.org with ESMTP id S932177AbWGLEJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 00:09:45 -0400
To: Andreas Kleen <ak@suse.de>
In-Reply-To: <121226.1152672894714.SLOX.WebMail.wwwrun@imap-dhs.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Kleen wrote:
> If it helps I can do a proper patch that only bounces IO > 4GB through
> the copy.

For the A8V series of boards, that will almost certainly be just fine, 
because as far as I know you can't populate them with more than 4G of 
memory anyway.

If someone has more than 4G of memory, it's likely they'll be willing to 
take the performance hit from the mod in exchange for being able to use 
more than 4G of memory.

Bottom line: do the patch.  It'll be worth using.


- Kevin

