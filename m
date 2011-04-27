From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH] igb: restore EEPROM 16kB access limit
Date: Wed, 27 Apr 2011 08:01:35 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016B41297D@orsmsx508.amr.corp.intel.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
 <4D9F6A44.7060809@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85E47@orsmsx508.amr.corp.intel.com>
 <20110426150659.GA21309@gospo.rdu.redhat.com>
 <EDC0E76513226749BFBC9C3FB031318F016AF39010@orsmsx508.amr.corp.intel.com>
 <20110427141542.GB21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35710 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197Ab1D0PBi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 11:01:38 -0400
In-Reply-To: <20110427141542.GB21309@gospo.rdu.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Andy Gospodarek [mailto:andy@greyhouse.net]
>Sent: Wednesday, April 27, 2011 7:16 AM
>To: Wyborny, Carolyn
>Cc: Andy Gospodarek; Stefan Assmann; netdev@vger.kernel.org; e1000-
>devel@lists.sourceforge.net; Kirsher, Jeffrey T; Pieper, Jeffrey E;
>Ronciak, John
>Subject: Re: [PATCH] igb: restore EEPROM 16kB access limit
>
>On Tue, Apr 26, 2011 at 08:12:20AM -0700, Wyborny, Carolyn wrote:
>[...]
>> Part of the problem you are seeing is an apparently widespread EEPROM
>problem where the size word in the EEPROM is invalid.  Since we didn't
>really check it before it didn't cause a problem.  I have a patch coming
>that addresses this by messaging the user that the size is invalid but
>setting it to a default and continuing.
>>
>
>It wasn't really a problem for me until the commit Stefan mentioned
>4322e561a93ec7ee034b603a6c610e7be90d4e8a was applied.
>
>I'm glad you are planning a fix for it, but I hope it can be out soon
>and not held up for too long by other patches planned for the next
>update.

Yes, the problem wasn't there before because of a bug in the code.  The bad EEPROM's have apparently been out there a while and are now being exposed, now that the code is fixed.  We didn't see one in our test of the fix originally or know there were out there until the reports starting coming in.

I'm pushing the fix through as soon as possible.  Its in test now.  I apologize for the delay.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation


