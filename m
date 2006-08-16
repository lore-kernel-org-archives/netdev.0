From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [E1000-devel] e1000: ethtool -p + cable pull = system wedges hard
Date: Wed, 16 Aug 2006 08:39:38 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F526B3588@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23331 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932076AbWHPPlH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 11:41:07 -0400
Content-class: urn:content-classes:message
To: <fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke-jan H wrote:
> Auke Kok wrote:
>> Jay Vosburgh wrote:
>>> 	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
>>> the e1000 in netdev-2.6#upstream (7.1.9-k4).
>>> 
>>> 	Starting up "ethtool -p ethX" then unplugging the cable
>>> connected to the identified port is causing my system to completely
>>> freeze; even sysrq is unresponsive.  I'm running on a 2-way x86
>>> box, with an 82545GM. 
>>> 
>>> 	Is this by any chance a known problem?
>> 
>> not at all.
> 
> One of my brain halves (the third one ;)) poked me and told me that
> it *is* a known issue. Not good. Apparently as early as kernel 2.5.50
> a change was introduced that causes this. I am unsure what exactly
> caused it and I assume it is generic (other nic's might also suffer).
> The issue is documented in our standalone driver documentation. Not
> sure what to do with this. 

Has something to do with the RTNL lock being held and link notification,
as I remember.
We noticed it to be a global problem, happens with e100 too.

http://www.mail-archive.com/netdev@vger.kernel.org/msg01654.html

Jesse
