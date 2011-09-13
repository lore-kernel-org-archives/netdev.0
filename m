From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next 2/2] qlcnic: Change CDRP function
Date: Tue, 13 Sep 2011 13:28:30 -0700
Message-ID: <33055D09-742C-4751-9A4B-1AF11ED34E31@qlogic.com>
References: <1315937179-22383-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1315937179-22383-2-git-send-email-anirban.chakraborty@qlogic.com>
 <1315938171.25776.11.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:8445
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932524Ab1IMU3o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 16:29:44 -0400
In-Reply-To: <1315938171.25776.11.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 13, 2011, at 11:22 AM, Joe Perches wrote:

> On Tue, 2011-09-13 at 11:06 -0700, Anirban Chakraborty wrote:
>> Argument list to CDRP function has become unmanageably long. Fix it by properly
>> declaring a struct that encompasses all the input and output parameters.
> 
> I don't think this is better.
> 
> I think you've overloaded the issue_cmd function and should
> use separate issue_cmd_<type> functions instead.

I did not overload issue_cmd(), instead I changed the function signature. 

-u32
-qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
-       u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd,
-               u32 *rd_args[3])
+void
+qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)

Instead of having a long list of arguments, I put them into a struct and passed it around.

-Anirban
