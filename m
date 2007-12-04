From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue,  4 Dec 2007 18:48:47 +0200
Message-ID: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46126 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbXLDQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:48:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are couple of fixes to net-2.6. The first one is to FRTO
which may fix some corner-case bug if the hand-coded check and
the !tcp_may_send_now disagree. I didn't check the differences
that carefully so they might agree after considering what FRTO
overrides from there, however, it makes the code much much more
obvious.

...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
as lower bound even though the ssthresh was already halved, 
so snd_ssthresh should suffice.

...While doing this, I had to did read a lot of related history,
thanks everyone about commit messages you have bothered to write
back then :-).

-- 
 i.


