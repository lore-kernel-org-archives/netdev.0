From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Wed, 08 Aug 2007 11:32:34 -0400
Message-ID: <1186587154.5155.43.camel@localhost>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rdreier@cisco.com, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:20586 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935766AbXHHPci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 11:32:38 -0400
Received: by el-out-1112.google.com with SMTP id j27so34636elf
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2007 08:32:37 -0700 (PDT)
In-Reply-To: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-08 at 08:14 -0700, Shirley Ma wrote:

> Dave, could you please hold this portion of the patch for a moment. I
> will test this patch ASAP. According to our previous experience, this
> changes significant changes some IPoIB driver performance.
> 
If you adjust your quantum while doing that testing you may find an
optimal value. 
Think of a box where you have other network interfaces, the way you
are implementing currently implies you are going to be very unfair to 
the other interfaces on the box. 

cheers,
jamal  


