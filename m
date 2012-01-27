From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] Implement =?UTF-8?Q?IP=5FUNICAST=5FIF=20socket=20opti?=  =?UTF-8?Q?on=2E?=
Date: Fri, 27 Jan 2012 10:01:48 +0100
Message-ID: <e75bbc09f45a13abdaccb7ef0de5e7e0@localhost>
References: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:51841 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750984Ab2A0JBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 04:01:51 -0500
In-Reply-To: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 26 Jan 2012 16:57:48 -0700, "Erich E. Hoover" wrote:



> The IP_UNICAST_IF feature is needed by the Wine project.  This patch

> implements the feature by setting the outgoing interface in the same

> fashion as that of IP_PKTINFO.



Why duplicate functionality - rewrite your application and use IP_PKTINFO

or bind() your socket. This patch duplicate already existing functionality

(and bloat inet_sock unnecessarily).



Hagen
