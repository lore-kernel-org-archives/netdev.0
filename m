From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [BUG?] iproute2/skbedit bug?
Date: Wed, 4 Mar 2009 13:46:47 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F2C0F5D6C@orsmsx501.amr.corp.intel.com>
References: <200903042146.37807.denys@visp.net.lb>
 <80769D7B14936844A23C0C43D9FBCF0F2C0F5D33@orsmsx501.amr.corp.intel.com>
 <200903042342.09287.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58065 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751AbZCDVrL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 16:47:11 -0500
In-Reply-To: <200903042342.09287.denys@visp.net.lb>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> On Wednesday 04 March 2009 23:36:07 Duyck, Alexander H wrote:
>>
>> Are you using the latest version off of the git tree or the version
>> tagged v2.6.28?  There was a fix applied 13 days ago to the git tree
>> version which resolves an issue with uninitialized memory being used
>> in configuring the skbedit action.  This was causing "File Exists"
>> errors similar to what you are seeing now.
>>
> 2.6.29-rc6-git7
> I will try rc7 now

Are you talking about the kernel or the iproute package?  The git tree I was referring to was the iproute tools package.

http://www.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Thanks,

Alex
