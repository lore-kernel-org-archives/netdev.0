From: Michael Stone <michael@laptop.org>
Subject: RFC: Network privilege separation.
Date: Wed,  7 Jan 2009 00:48:53 -0500
Message-ID: <1231307334-9542-1-git-send-email-michael@laptop.org>
Cc: netdev@vger.kernel.org, Michael Stone <michael@laptop.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:57353 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751470AbZAGF6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 00:58:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear lkml and netdev,

I'm trying to implement a kernel facility for unprivileged processes to
irrevocably discard their and their future children's ability to perform
unrestricted network I/O. (Restricted network I/O, e.g. on sockets which were
connected before the privilege-reduction or on filesystem-based sockets is
okay.)

I want the kernel to provide a facility like this one because such a facility
will make it much easier for users, authors, and distributors of userland
software to protect themselves and one another from a broad class of malicious
software.

For the sake of discussion, I have written up and documented one possible
implementation of this concept based on the idea of a new rlimit named
RLIMIT_NETWORK in the following patch series. 

I eagerly await your questions, comments, suggestions, and improvements.

Thanks very much,

Michael

P.S. - I'm not subscribed to either lkml or netdev, so please CC me on
responses. Thanks!
