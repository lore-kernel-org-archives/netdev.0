From: Joe Perches <joe@perches.com>
Subject: Re: CodingStyle parenthesis alignment: was: Re: align to open paren
Date: Wed, 15 Apr 2015 18:29:23 -0700
Message-ID: <1429147763.2850.33.camel@perches.com>
References: <40F65EF2B5E2254199711F58E3ACB84D781CD892@MX104CL02.corp.emc.com>
	 <1429131997.2850.15.camel@perches.com>
	 <40F65EF2B5E2254199711F58E3ACB84D781CD94F@MX104CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "apw@canonical.com" <apw@canonical.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Hubbe, Allen" <Allen.Hubbe@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0226.hostedemail.com ([216.40.44.226]:57749 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751416AbbDPB31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 21:29:27 -0400
In-Reply-To: <40F65EF2B5E2254199711F58E3ACB84D781CD94F@MX104CL02.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 21:54 +0000, Hubbe, Allen wrote:
> I ran with the --fix option, and it changed every rejected indent to
> match the column of the open paren.  That's probably what you want,
> since it's the most consistent with the previous behavior.  The
> difference is that it does not fix lines that are no longer rejected,
> like if they are indented by two per paren.  The test file and output
> are attached.

There might be some utility adding a --style=<foo>
switch so checkpatch can appropriately warn on
K&R vs linux vs bsd vs gnu vs otb, etc...
