From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/3] l2tp: module autoloading
Date: Wed, 23 Sep 2015 21:33:33 -0700
Message-ID: <20150924043333.231895827@networkplumber.org>
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36759 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbIXEer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 00:34:47 -0400
Received: by pacgz1 with SMTP id gz1so11170473pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 21:34:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With L2TP it was necessary to manually load modules
which is a nuisance and not required with other tunneling
protocols. This set of patches adds the aliases and module
load hook to get rid of the necessity of modprobing.
