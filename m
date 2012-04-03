From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net] bnx2x: correction to firmware interface
Date: Tue, 3 Apr 2012 16:06:51 -0700
Message-ID: <1333494411.12280.19.camel@nseg_linux_HP1.broadcom.com>
References: <1333447631-18536-1-git-send-email-yuvalmin@broadcom.com>
 <20120403.190408.54610555291057345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com,
	eilong@broadcom.com, bprakash@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3515 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946Ab2DCXWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 19:22:21 -0400
In-Reply-To: <20120403.190408.54610555291057345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2012-04-03 at 19:04 -0400, David Miller wrote:
> From: "Yuval Mintz" <yuvalmin@broadcom.com>
> Date: Tue, 3 Apr 2012 13:07:11 +0300
> 
> > Commit 621b4d6 updated the bnx2x driver to a new FW version, but lacked
> > a commit to a header file with changes to the firmware's interface. 
> > The missing interface change causes iscsi and fcoe to misbehave with the 
> > updated firmware.
> > 
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > CC: Michael Chan <mchan@broadcom.com>
> > CC: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> 
> Applied, how far back do -stable releases need this fix?
> 

No need to submit to any -stable release.  This problem is present in
the current net tree and Linux tree only.  Thanks.
