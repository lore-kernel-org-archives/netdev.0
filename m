From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Is TCP vulneribility patch (as in RFC 5961) done in linux?
Date: Mon, 16 Jul 2012 10:35:47 +0200
Message-ID: <1342427747.4812.2.camel@edumazet-glaptop>
References: <68700EDA775E5E47B5EBA9FF8AC0F15C076B03@SJEXCHMB09.corp.ad.broadcom.com>
	 <68700EDA775E5E47B5EBA9FF8AC0F15C077FF3@SJEXCHMB09.corp.ad.broadcom.com>
	 <1342427617.4812.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kiran (Kiran Kumar) Kella" <kkiran@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40057 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab2GPIfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 04:35:53 -0400
Received: by eaak11 with SMTP id k11so1555694eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 01:35:49 -0700 (PDT)
In-Reply-To: <1342427617.4812.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 10:33 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-16 at 07:06 +0000, Kiran (Kiran Kumar) Kella wrote:
> > Looking into the file tcp_input.c in the latest stable linux release 3.4.4 source, I understand the fix for this recommendation is not implemented in Linux.
> > Any reason why it was not addressed?
> 
> Nobody cared ?
> 
> Are you planning to send a patch ?
> 

By the way, if the attacker replaces the RST bit by FIN bit, how
are we going to deal with the problem ?

Also many middleboxes will drop the challenge ACK...
