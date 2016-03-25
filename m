From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH net-next v3.16]r8169:  Correct value from speed 10 on
 MII_BMCR
Date: Fri, 25 Mar 2016 14:33:02 +0100
Message-ID: <20160325133113.3001B62813@mail.nwl.cc>
References: <1458910866-21784-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58663 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbcCYNbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 09:31:16 -0400
Content-Disposition: inline
In-Reply-To: <1458910866-21784-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Your patch submissions are getting better, also good to see you're
finally using git-send-email. A few things need to be corrected though:

Subject line:
- The 'vNN' part in brackets is supposed to be the reroll-count (see
  'git format-patch -h' for details), not kernel version. You're
  supposed to submit your patches for either net or net-next, not a
  specific kernel version like 3.16.
- Missing space after the closing bracket.
- Extra space after 'r8169:'.

On Fri, Mar 25, 2016 at 03:01:06PM +0200, Corcodel Marian wrote:
>  This patch correct value on MII_BMCR register ald value 0
>  have target on reserved register first 2 bytes from MII_BMCR
>  speed 10 is flipped value on BMCR_SPEED100

This is very hard to understand. I *guess* you want to say one should
not write 0 to MII_BMCR since it overwrites reserved bits, but it's
really not clear. Don't you know someone who can properly translate from
Romanian to English?

Also detailed instructions on how to trigger the problem you are fixing
for would be good. In detail: Which specific hardware was used, in which
situation did the problem occur, how did it behave in that situation and
what was the expected behaviour?

Cheers, Phil
