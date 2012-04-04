From: Jing Huang <huangj@Brocade.COM>
Subject: RE: [PATCH 0/7] bna: Update driver version to 3.0.23.0
Date: Wed, 4 Apr 2012 16:46:21 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B3A74DEE7C@HQ1-EXCH01.corp.brocade.com>
References: <1332790673-9562-1-git-send-email-huangj@brocade.com>
	<20120404101535.0b739155@s6510.linuxnetplumber.net>
 <20120404.181718.345441045492163774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39766 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932579Ab2DDXqf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 19:46:35 -0400
In-Reply-To: <20120404.181718.345441045492163774.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> When are you going to integrate multi-queue support which is already
>> available in your out of tree driver?
>
>I hope your Brocade folks aren't playing the "try to make the out-of-tree
>driver more desirable than the in-tree one" game.  I would find that really
>irritating.

Hi Stephen & David

We submitted our mutli-TX queue implementation last year but it was not accepted. The concern was mainly on our iSCSI over DCB implementation because we had used select_queue() to map iSCSI pkts to a queue derived from DCB configuration by inspecting the well known TCP port number. The community feedback was to use ndo_setup_tc to setup up priority to queue mapping and use dcb_setapp() routines to program the iscsi TLV and provide priority info to user space applications. 

We are working on the implementation for our next driver release and will plan to submit the upstream patch after it has gone through QA validation later this year.

However, if you are ok with the existing implementation, we would like to resubmit the current implementation to enable feature parity with out of box driver.

Thanks
Jing
