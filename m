From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: Adding FW 7.0.29.0
Date: Mon, 24 Oct 2011 15:57:56 +0200
Message-ID: <1319464676.6155.3.camel@lb-tlvb-dmitry>
References: <1318860047-5044-1-git-send-email-dmitry@broadcom.com>
 <1318867968.5817.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "dwmw2@infradead.org" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2777 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932641Ab1JXN6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 09:58:11 -0400
In-Reply-To: <1318867968.5817.1.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2011-10-17 at 09:12 -0700, Dmitry Kravkov wrote:
> On Mon, 2011-10-17 at 07:00 -0700, Dmitry Kravkov wrote:
> > Includes fixes for the following issues:
> >   1. (iSCSI) Arrival of un-solicited ASYNC message causes
> >      firmware to abort the connection with RST.
> >   2. (FCoE) There is a probability that truncated FCoE packet on
> >      RX path won't get detected which might lead to FW assert.
> >   3. (iSCSI) Arrival of target-initiated NOP-IN during intense
> >      ISCSI traffic might lead to FW assert.
> >   4. (iSCSI) Chip hangs when in case of retransmission not aligned
> >      to 4-bytes from the beginning of iSCSI PDU.
> >   5. (FCoE) Arrival of packets beyond task IO size can lead to crash.
> > 

David, do you have estimation to handle the request? We have pending
patch for net-next. Thanks.
