From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: eSwitch management
Date: Thu, 22 Apr 2010 18:29:40 -0700
Message-ID: <C7F64614.2ADDF%scofeldm@cisco.com>
References: <C7F63C44.2ADAE%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Scott Feldman <scofeldm@cisco.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:32287 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab0DWB3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 21:29:44 -0400
In-Reply-To: <C7F63C44.2ADAE%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/10 5:47 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:

> On 4/22/10 4:16 PM, "Anirban Chakraborty" <anirban.chakraborty@qlogic.com>
> wrote:
> 
>> I am following the discussions on iovnl patch closely. While it is going to
>> take some time for iovnl patch to be reviewed and accepted, what would be the
>> interim approach to manage the eswitch in NIC? We need to add support in
>> qlcnic driver to configure the eswitch in our 10G NIC. Some of the things
>> that
>> we need to set to the switch are setting a port's VLAN, tx bandwidth etc. We
>> would like to set these parameters for a bunch of ports at the start of the
>> day and set it to the eswitch.
> 
> Are any of these settings covered in DCB?  (net/dcb/dcbnl.c).  Maybe you can
> get a start there?  Not sure not knowing your device requirements.

Or maybe the RTM_SETLINK IFLA_VF_* ops in include/linux/if_link.h?  Those
seem like what you're looking for.  I'm looking at moving iovnl here as well
for port-profile.

-scott

