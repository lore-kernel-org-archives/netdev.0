From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/5] remove TxStartThresh and RxEarlyThresh
Date: Mon, 16 Oct 2006 07:26:37 +1000
Message-ID: <1160947597.22522.3.camel@localhost.localdomain>
References: <1160855725.2266.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40913 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1030250AbWJOV1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 17:27:21 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1160855725.2266.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-10-14 at 15:55 -0400, Jesse Huang wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs:
> For patent issue need to remove TxStartThresh and RxEarlyThresh. This patent 
> is cut-through patent. If use this function, Tx will start to transmit after 
> few data be move in to Tx FIFO. We are not allow to use those function in 
> DFE530/DFE550/DFE580/DL10050/IP100/IP100A. It will decrease a little 
> performance.

Somebody patented FIFO thresholds ? Gack ?

Ben.


