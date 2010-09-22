From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] atl1: fix resume
Date: Wed, 22 Sep 2010 13:23:41 -0700 (PDT)
Message-ID: <20100922.132341.48506736.davem@davemloft.net>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
	<1284717403-12913-1-git-send-email-kronos.it@gmail.com>
	<AANLkTik_0je-8M7VPGy5e05KgOCM8F_rM6b6xUQOPsKy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: kronos.it@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752209Ab0IVUXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:23:22 -0400
In-Reply-To: <AANLkTik_0je-8M7VPGy5e05KgOCM8F_rM6b6xUQOPsKy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Tettamanti <kronos.it@gmail.com>
Date: Wed, 22 Sep 2010 21:34:25 +0200

> On Fri, Sep 17, 2010 at 11:56 AM, Luca Tettamanti <kronos.it@gmail.com> wrote:
>> adapter->cmb.cmb is initialized when the device is opened and freed when
>> it's closed. Accessing it unconditionally during resume results either
>> in a crash (NULL pointer dereference, when the interface has not been
>> opened yet) or data corruption (when the interface has been used and
>> brought down adapter->cmb.cmb points to a deallocated memory area).
>>
>> Cc: stable@kernel.org
>> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
>> Acked-by: Chris Snook <chris.snook@gmail.com>
> 
> Ping?

For some reason these resubmissions make it to netdev nor patchwork,
could you please try sending these two patches again?

Thanks!
