From: Chris Friesen <chris.friesen@genband.com>
Subject: ip fragments sent in reverse order?
Date: Thu, 26 May 2011 07:56:09 -0600
Message-ID: <4DDE5BF9.6090508@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:42262 "EHLO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab1EZXXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 19:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I read that Linux intentionally sends IP fragments in reverse order to 
allow for some optimization on the receive side.  I'm trying to find 
this code, but what I see in ip_fragment() seems to be creating/sending 
the fragments in order.  Has this changed over the years?

Thanks,
Chris


	
-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
