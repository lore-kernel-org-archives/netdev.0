From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with newer Loss Intervals Database
Date: Tue, 11 Dec 2007 09:42:38 +0000
Message-ID: <20071211094238.GA9926@gerrit.erg.abdn.ac.uk>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk> <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882049-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881748-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk> <20071210210416.GB24046@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37144 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750735AbXLKJnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 04:43:23 -0500
Content-Disposition: inline
In-Reply-To: <20071210210416.GB24046@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| When interfacing we must make sure that ccid3 tfrc_lh_slab is created
| and then tfrc_li_cachep is not needed. I'm doing this while keeping
| the structure of the patches, i.e. one introducing, the other removing.
| But we need to create tfrc_lh_slab if we want the tree to be bisectable.
| 
| I'm doing this and keeping your Signed-off-line, please holler if you
| disagree for some reason.
If you are just shifting and reordering then that is fine with me. But
it seems you mean a different patch since in this one there is no slab
initialisation. 
The loss history and the RX/TX packet history slabs are all created in
tfrc.c using the three different __init routines of the dccp_tfrc_lib.
