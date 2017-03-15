From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT] the new ksetting methods in subnet's subdrivers
Date: Wed, 15 Mar 2017 16:02:39 +0100
Message-ID: <20170315150248.10997-1-oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59842 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753467AbdCOPDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:39 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id DE41AAC4A
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:37 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The API for ethtool has been changed. Rather than implement the change
sparately in each subdriver, usbnet should be changed and the subdrivers
should expand upon the generic method usbnet provides.
This set implements the new methods, introduces them into the subdrivers
and rips out the old stuff, lest it be used in new drivers.
