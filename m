From: Pascal Terjan <pterjan@mandriva.com>
Subject: 8139cp vs 8139too, request_module ?
Date: Wed, 10 Jun 2009 18:02:09 +0200
Message-ID: <1244649729.14601.1.camel@plop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ryu.zarb.org ([212.85.158.22]:36452 "EHLO ryu.zarb.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbZFJQCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 12:02:10 -0400
Received: from localhost (localhost [127.0.0.1])
	by ryu.zarb.org (Postfix) with ESMTP id 9B9893F62E
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 18:02:12 +0200 (CEST)
Received: from ryu.zarb.org ([127.0.0.1])
	by localhost (ryu.zarb.org [127.0.0.1]) (amavisd-new, port 10025)
	with ESMTP id IcqlJHsZpzlM for <netdev@vger.kernel.org>;
	Wed, 10 Jun 2009 18:02:11 +0200 (CEST)
Received: from [192.168.100.212] (office-abk.mandriva.com [84.55.162.90])
	by ryu.zarb.org (Postfix) with ESMTPSA id 2887D3F62D
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 18:02:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
8139cp and 8139too both handle the same id and then test revision.

If revision is wrong they tell to load the other module and return
ENODEV.

Why not doing a request_module instead of printing a message ? 

