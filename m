From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 05/14] i40evf: fix up strings in init task
Date: Fri, 14 Feb 2014 16:05:55 -0800
Message-ID: <1392422755.12157.8.camel@joe-AO722>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
	 <1392418688-23895-6-git-send-email-aaron.f.brown@intel.com>
	 <1392421409.12157.3.camel@joe-AO722>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65517F5F@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:43340 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752948AbaBOAF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 19:05:59 -0500
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65517F5F@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-14 at 23:53 +0000, Williams, Mitch A wrote:
> With regard to periods on the end of log messages,
> is this a hard rule?

No.

>  The grammar pedant in me likes to see periods on the end of sentences,

Opinions vary.

I think kernel logging output lines aren't sentences
and are just notifications that don't need periods.

If you look at a normal log, there are relatively few
entries with periods.

For instance, my current dmesg:

$ dmesg | wc -l
1568
$ dmesg | grep "[^\.]\.$" | wc -l
84
