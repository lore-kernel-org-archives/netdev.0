From: Ofer Heifetz <oferh@marvell.com>
Subject: Splice status
Date: Mon, 5 Jul 2010 12:26:03 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:41033 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab0GEJcl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 05:32:41 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have been trying to test splice on kernel 2.6.35_4 (x86) from Samba (v3.4.7) but could not copy more than ~60MB to the Samba server share.

Strace shows that the splice got stuck in blocking mode on the splice call from socket to pipe.

Has anyone managed to get splice from socket to fd work for large files (up to 4G file size) ?

-Ofer
