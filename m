From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 0/1] tlan cleanup fix
Date: Wed, 09 Feb 2011 22:24:46 +0200
Message-ID: <4D52F80E.9030307@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:50476 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1BIUYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 15:24:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Dan Carpenter found a problem in my last tlan cleanup patch. In the 
cleanup, I accidentally considered a bit mask containing multiple bits 
set as one containing a single bit set. The following patch fixes this 
issue.

Regards,

-- 
Sakari Ailus
sakari.ailus@iki.fi
