From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [dccp] [RFC/RFT] [Patch 0/2]: Test-tree update to handle
	retransmissions correctly
Date: Thu, 5 Jun 2008 15:44:35 +0100
Message-ID: <20080605144435.GA8800@gerrit.erg.abdn.ac.uk>
References: <4846462F.3020004@cn.fujitsu.com> <20080604132152.GA17595@ghostprotocols.net> <20080604133849.GA5583@gerrit.erg.abdn.ac.uk> <20080604154452.GB4625@ghostprotocols.net> <20080604155540.GA16194@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Wei Yongjun <yjwei@cn.fujitsu.com>,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61093 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753129AbYFEOou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:44:50 -0400
Content-Disposition: inline
In-Reply-To: <20080604155540.GA16194@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are two patches for the test tree. As with all RFC/RFT patches, these are
posted with the main objective of getting review/comments, and are then put into
the test tree for ... testing.

These patches evolved thanks to input provided by Wei Yongjun regarding an
unresolved problem with retransmissions, fixed by the following two updates:

Patch #1: allows to distinguish retransmitted from original packets,
          using a slight reordering of existing code.
          This is the main fix for the earlier problem of not incrementing
	  the sequence number properly on retransmitted Request packets.

	  The patch introduces a generic condition which can also be tested
	  by other code (e.g. for the retransmission of Close/CloseReq).

Patch #2: puts two strongly related statements, dccp_entail() and
          skb_clone() both in dccp_entail(), since they are not 
	  independent. Patch can be a matter of taste and may be omitted.


The patches are not yet committed - if there are no major objections, they will
be added to the test tree tomoroow, on 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree dccp)

with snapshots on
	http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.tar.bz2
	http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.diff.gz
