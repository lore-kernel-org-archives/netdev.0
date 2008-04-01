From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Setting alternate MAC addresses on e1000
Date: Tue, 1 Apr 2008 10:17:48 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204D09A67@orsmsx418.amr.corp.intel.com>
References: <47F2358A.8080505@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>
To: "Carsten Aulbert" <carsten.aulbert@aei.mpg.de>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34104 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939AbYDARSA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 13:18:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47F2358A.8080505@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carsten Aulbert wrote:
> where magic is MAGIC=0x108c8086
> 
> However this does not work on eth1 :(

I think you need a different MAGIC for eth1 since they are separate
parts (different device ID) with separate eeproms, then the first 6 byte
change should work for eth1 too.

in the future e1000-devel@lists.sf.net might be more appropriate to
Intel specific hardware questions.  but copying netdev is still okay.

Thanks,
  Jesse
