From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: eSwitch management
Date: Thu, 22 Apr 2010 22:57:51 -0700
Message-ID: <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
References: <C7F64614.2ADDF%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:43259 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860Ab0DWF5w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 01:57:52 -0400
In-Reply-To: <C7F64614.2ADDF%scofeldm@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 22, 2010, at 6:29 PM, Scott Feldman wrote:

> On 4/22/10 5:47 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
> 
>> On 4/22/10 4:16 PM, "Anirban Chakraborty" <anirban.chakraborty@qlogic.com>
>> wrote:
>> 
>>> I am following the discussions on iovnl patch closely. While it is going to
>>> take some time for iovnl patch to be reviewed and accepted, what would be the
>>> interim approach to manage the eswitch in NIC? We need to add support in
>>> qlcnic driver to configure the eswitch in our 10G NIC. Some of the things
>>> that
>>> we need to set to the switch are setting a port's VLAN, tx bandwidth etc. We
>>> would like to set these parameters for a bunch of ports at the start of the
>>> day and set it to the eswitch.
>> 
>> Are any of these settings covered in DCB?  (net/dcb/dcbnl.c).  Maybe you can
>> get a start there?  Not sure not knowing your device requirements.
> 
> Or maybe the RTM_SETLINK IFLA_VF_* ops in include/linux/if_link.h?  Those
> seem like what you're looking for.  I'm looking at moving iovnl here as well
> for port-profile.

It looks like ifla_vf_info does contain most of the data set. But if I use it, what NETLINK protocol family should I use in my driver to receive netlink messages? Do I need to create a private protocol family?

Thanks a lot,
Anirban

