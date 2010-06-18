From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [Bugme-new] [Bug 16187] New: Carrier detection failed in	dhcpcd
 when link is up
Date: Fri, 18 Jun 2010 08:04:36 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A900158F12BEA@orsmsx509.amr.corp.intel.com>
References: <bug-16187-10286@https.bugzilla.kernel.org/>
 <20100615142418.f47e8abd.akpm@linux-foundation.org>
 <20100618061641.GA7039@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"casteyde.christian@free.fr" <casteyde.christian@free.fr>
To: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933599Ab0FRPEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 11:04:39 -0400
In-Reply-To: <20100618061641.GA7039@lackof.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, June 17, 2010 11:17 PM, Grant Grundler wrote:
> On Tue, Jun 15, 2010 at 02:24:18PM -0700, Andrew Morton wrote:
>> 
>> (switched to email.  Please respond via emailed reply-to-all, not
>> via the bugzilla web interface).
> 
> I've resync to linus' tree (2.6.35-rc3) and reviewed the output of:
>     git diff v2.6.34 drivers/net/tulip/
> 
> I don't see anything that would affect how link state
> changes get reported to user space.
> 
> I'm not inclined to believe this is a tulip "bug" unless
> core netdev behavior changed and tulip is not longer
> doing the right thing.
> 
> hth,
> grant

I don't believe this is a tulip specific bug - the same thing has been reported against e1000e and bnx2 (IIRC); I have not had the time to investigate further.

Bruce.