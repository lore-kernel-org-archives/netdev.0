From: Florian Fainelli <florian.fainelli@int-evry.fr>
Subject: Network activity LED trigger
Date: Thu, 1 Mar 2007 22:41:48 +0100
Message-ID: <200703012241.49165.florian.fainelli@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:56085 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030457AbXCAWUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 17:20:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I have been talking a bit with Richard, who is the LED API maintainer, and a 
LED trigger based on network activity would be something great.

There are somethings that concern the network stack :

- should we specify if the network driver is allowed to contribute to
the LED activity, just like it is done for random generation, at compile time

- I would like to trigger the LED based on one or several network
interfaces, maybe specify via sysfs which interface triggers which LED,
and also maybe differentiate the layer-2 activity from the layer-3
activity for instance

- A led driver could by default be bound to a network driver, or an interface 
name

As it could be very intrusive in the network stack, you might want to specify 
a bit more how you imagine a network activity trigger.

Thanks
-- 
