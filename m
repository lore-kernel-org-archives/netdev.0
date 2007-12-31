From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 0/9]: TCP cleanups & minor changes.
Date: Mon, 31 Dec 2007 12:47:48 +0200
Message-ID: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45709 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723AbXLaKr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:47:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The first one is restored after getting removed in the
straight-forward revert we did.

Please check that the TCPCB_URG removal is indeed valid. I couldn't
find any use for it but there might be some non-obviously named
things I've missed.

I did a larger cleanup with indent for tcp_input and tcp_output
because I started to find so many unnecessarily line split &
missing spaces here and there. There's still a lot to do because
not every case has a trivial solution but at least something got
cleaner :-).

These should apply cleanly to the rebased net-2.6.25. I did some
trivial test with them before the rebase.                        
                                                    
   
-- 
 i.


