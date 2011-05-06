From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: Consistently disable irqs when
 taking adapter->cmd_lock
Date: Fri, 06 May 2011 13:12:11 -0700 (PDT)
Message-ID: <20110506.131211.39193090.davem@davemloft.net>
References: <1304706773-21348-1-git-send-email-roland@kernel.org>
	<alpine.LRH.2.00.1105061206500.26660@sbhatewara-dev1.eng.vmware.com>
	<F78BCF638F95D74A99D036114107EDB5028EFAA0F8@EXCH-MBX-3.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, roland@kernel.org, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: scottjg@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754292Ab1EFUMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 16:12:43 -0400
In-Reply-To: <F78BCF638F95D74A99D036114107EDB5028EFAA0F8@EXCH-MBX-3.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Goldman <scottjg@vmware.com>
Date: Fri, 6 May 2011 13:10:29 -0700

>> 
>> On Fri, 6 May 2011, Roland Dreier wrote:
>> 
>> > From: Roland Dreier <roland@purestorage.com>
>> >
>> > Using the vmxnet3 driver produces a lockdep warning because
>> 
>> > Signed-off-by: Roland Dreier <roland@purestorage.com>
>> 
>> 
>> Roland, thanks for the analysis and the patch.
>> 
>> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> 
> Likewise, seems pretty sane to me. The command register operations are only control-path operations and disabling interrupts for the duration is probably not a big deal. Touching the cmd reg will result a VMEXIT, where the guest won't be processing interrupts anyway. 
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

Applied, thanks everyone.
