From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2] mcastv6: Local variable shadows function argument
Date: Mon, 20 Jul 2009 07:50:06 -0700
Message-ID: <OF77DEEF36.77254995-ON882575F9.005123F7-882575F9.00517F6B@us.ibm.com>
References: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:45430 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbZGTOuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:50:20 -0400
In-Reply-To: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pmc->idev should be equal to idev, so you should be able
to simply remove the extra declaration and leave the other
code as it is-- i.e., a 1-line change.

                                        +-DLS

