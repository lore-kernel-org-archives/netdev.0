From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs interfaces
Date: Thu, 05 Sep 2013 16:38:15 -0700
Message-ID: <522915E7.8010308@intel.com>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com> <1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com> <20130904173759.7c2eec52@nehalam.linuxnetplumber.net> <FC41C24E35F18A40888AACA1A36F3E416C6249AD@FMSMSX102.amr.corp.intel.com> <20130905113259.55ad2ad2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:17664 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753734Ab3IEXij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 19:38:39 -0400
In-Reply-To: <20130905113259.55ad2ad2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2013 11:32 AM, Stephen Hemminger wrote:

[...]

>
> IMHO  attributes are a nice way of handling the VSI attributes since they
> seem hardware specific.  Not sure how to do the right thing with switching.
> Should it look like Macvlan, bridge, VXLAN, or something else.

I think if you add a new rtnl link type call it "VSI" then it looks very
similar to a macvlan which has been offloaded. Additionally you get all
the fdb and ndo ops that already exist for free.

I proposed something similar here,

http://comments.gmane.org/gmane.linux.network/237617

although as Ben pointed out I screwed up the implementation. I'll work
on updating this to submit when net-next opens again.

.John
