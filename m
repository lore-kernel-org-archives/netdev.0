From: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Subject: [RFC]: add tracepoint to net_rx_action to note polling operations
Date: Mon, 20 Apr 2009 21:17:29 +0930
Message-ID: <20090420211729.2218e5e2.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:49257 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbZDTOdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 10:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(not on list, please CC me)

"I was thinking about adding an additional tracepoint to
net_rx_action, right before the call to dev->poll().  One of the things
thats missing from my dropwatch utility is the ability to detect
hardware drops, and I was thinking I could implement that by noting
when devices were being polled by napi, and at that time querying the
devices stats.

	I know however, that adding tracepoints isn't always
desireable, so I thought I would solicit opinions here to see if anyone
else would find such a tracepoint usefull, or in the event they had
strong objectsions to such a point."

Would that be indicating that the host isn't keeping up with the
incoming packet rate? If so, I'd think that would be quite useful, as
it'd be a very obvious indicator that the host needs a performance
upgrade, should the traffic be valid e.g. not a DoS attack.

Regards,
Mark.

